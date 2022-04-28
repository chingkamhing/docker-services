package main

import (
	"context"
	"errors"
	"flag"
	"fmt"
	"log"
	"math"
	"os"
	"time"

	"github.com/nats-io/nats.go"
)

//
// this code is from:
// https://stackoverflow.com/questions/71111758/nats-cannot-create-a-queue-subscription-for-a-consumer-without-a-deliver-group
//

const url = "localhost:4222"

var username = os.Getenv("NATS_USERNAME")
var password = os.Getenv("NATS_PASSWORD")
var numPubsub int
var numQueue int
var interval time.Duration
var duration time.Duration

func init() {
	log.SetFlags(0)
}

func main() {
	flag.IntVar(&numPubsub, "pubsub", 2, "Number of pubsub subscriber")
	flag.IntVar(&numQueue, "queue", 2, "Number of queue subscriber")
	flag.DurationVar(&interval, "interval", 100*time.Millisecond, "Publish interval")
	flag.DurationVar(&duration, "duration", 3*time.Second, "Publish duration")
	flag.Parse()
	stream := flag.Arg(0)
	topic := flag.Arg(1)
	// deliverSubject := stream + "Deliver"

	nc, err := nats.Connect(url, nats.UserInfo(username, password))
	if err != nil {
		log.Fatalf("unable to connect to nats: %v", err)
	}
	js, err := nc.JetStream()
	if err != nil {
		log.Fatalf("error getting jetstream: %v", err)
	}
	_, err = js.AddStream(&nats.StreamConfig{
		Name:     stream,
		Subjects: []string{topic},
	})
	switch {
	case err == nil:
	case errors.Is(err, nats.ErrStreamNameAlreadyInUse):
	default:
		log.Fatalf("can't add: %v", err)
	}

	{
		consumer := stream + "Consumer"
		info, err := createPushConsumer(js, stream, consumer, "")
		if err != nil {
			log.Fatalf("createPushConsumer: %v", err)
		}
		for i := 0; i < numPubsub; i++ {
			nc.Subscribe(
				info.Config.DeliverSubject,
				callbackSubscribe(i),
			)
		}
	}
	{
		queue := stream + "Queue"
		opts := []nats.SubOpt{
			nats.AckExplicit(),
			nats.DeliverNew(),
		}
		for i := 0; i < numQueue; i++ {
			js.QueueSubscribe(
				topic,
				queue,
				callbackQueue(i),
				opts...,
			)
		}
	}

	// our publisher thread
	ctx, cancel := context.WithTimeout(context.Background(), duration)
	defer cancel()
	go func() {
		for i := 0; i < math.MaxInt; i++ {
			msg := fmt.Sprintf("key %d", i)
			_, err = js.Publish(topic, []byte(msg))
			if err != nil {
				if errors.Is(err, context.DeadlineExceeded) {
					return
				}
				log.Printf("error publishing: %v", err)
			}
			// log.Printf("[publisher] sent %d", i)
			time.Sleep(interval)
		}
	}()
	for range ctx.Done() {
		// nothing to do
	}
	cancel()
	log.Printf("done stream %q testing", stream)
}

func createPushConsumer(js nats.JetStreamContext, stream, consumer string, filter string) (*nats.ConsumerInfo, error) {
	deliverSubject := "DeliverTopic." + consumer
	deliverGroup := "DeliverGroup." + consumer
	log.Printf("broker create push-based consumer %v > %v with filter %q; message will then be delivered to topic %v group %v", stream, consumer, filter, deliverSubject, deliverGroup)
	cfg := &nats.ConsumerConfig{
		Durable:        consumer,
		Description:    fmt.Sprintf("Durable push-based subscribe consumer %v > %v with filter %q", stream, consumer, filter),
		DeliverSubject: deliverSubject,
		DeliverGroup:   "",
		DeliverPolicy:  nats.DeliverNewPolicy,
		AckPolicy:      nats.AckNonePolicy,
		MaxDeliver:     -1,
		FilterSubject:  filter,
		ReplayPolicy:   nats.ReplayInstantPolicy,
		FlowControl:    false,
		Heartbeat:      30 * time.Second,
		HeadersOnly:    false,
	}
	// log stream info
	streamInfo, err := js.StreamInfo(stream)
	if err != nil {
		return nil, fmt.Errorf("broker StreamInfo(): %w", err)
	}
	log.Printf("stream %v info: description %v subjects %v", streamInfo.Config.Name, streamInfo.Config.Description, streamInfo.Config.Subjects)
	// Q: check if the stream consumer already exist, skip if it does
	info, err := js.ConsumerInfo(stream, consumer)
	switch {
	case errors.Is(err, nats.ErrConsumerNotFound):
	case err == nil:
		log.Printf("consumer %v info: stream %v NumAckPending %v NumRedelivered %v NumWaiting %v NumPending %v", info.Name, info.Stream, info.NumAckPending, info.NumRedelivered, info.NumWaiting, info.NumPending)
		log.Printf("broker consumer %v > %v already exist, skip creating consumer", stream, consumer)
		return info, nil
	default:
		return nil, fmt.Errorf("broker ConsumerInfo(): %w", err)
	}
	opts := []nats.JSOpt{}
	isSuccess := false
	for i := 0; i < 2 && !isSuccess; i++ {
		info, err = js.AddConsumer(stream, cfg, opts...)
		switch {
		case err == nil:
			log.Printf("consumer %v > %v just created", stream, consumer)
			isSuccess = true
		case err.Error() == "filter subject can not be updated":
			// need to delete the consumer first before filter can be changed
			log.Printf("broker delete consumer %v before it can change the filter", consumer)
			err := js.DeleteConsumer(stream, consumer)
			if err != nil {
				return nil, fmt.Errorf("broker DeleteConsumer(): %w", err)
			}
		default:
			return nil, fmt.Errorf("broker AddConsumer(): %w", err)
		}
	}
	return info, nil
}

func callbackSubscribe(index int) func(m *nats.Msg) {
	return func(m *nats.Msg) {
		log.Printf("Sub %d: %s", index, m.Data)
	}
}

func callbackQueue(index int) func(m *nats.Msg) {
	return func(m *nats.Msg) {
		log.Printf("Queue %d: %s", index, m.Data)
	}
}
