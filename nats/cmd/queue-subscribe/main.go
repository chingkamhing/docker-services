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
	// consumer := stream + "Consumer"
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
		opts := []nats.SubOpt{
			nats.AckNone(),
			nats.DeliverNew(),
		}
		for i := 0; i < numPubsub; i++ {
			_, err = js.Subscribe(
				topic,
				callbackSubscribe(i),
				opts...,
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
			_, err = js.QueueSubscribe(
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
