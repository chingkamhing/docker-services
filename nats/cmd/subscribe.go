package cmd

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"math"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/nats-io/nats.go"
	uuid "github.com/satori/go.uuid"
	"github.com/spf13/cobra"
)

//
// this code is from:
// https://gist.github.com/wallyqs/b01ba613341170b4442acbffcaea0a81
//

var cmdSubscribe = &cobra.Command{
	Use:   "sub [subject]",
	Short: "NATS subscribe related sub-commands",
	Args:  cobra.ExactArgs(1),
	Run:   runSubscribe,
}

var cmdSubscribeTestPull = &cobra.Command{
	Use:   "test-pull",
	Short: "Test NATS publish and subscribe pull-based message",
	Args:  cobra.ExactArgs(0),
	Run:   runSubscribeTestPull,
}

var cmdSubscribeTestQueue = &cobra.Command{
	Use:   "test-queue [stream] [subject]",
	Short: "Test NATS publish and subscribe queue message",
	Args:  cobra.ExactArgs(2),
	Run:   runSubscribeTestQueue,
}

var subIntervalCount int
var numPubsub int
var numQueue int
var interval time.Duration
var duration time.Duration

func init() {
	cmdSubscribe.AddCommand(cmdSubscribeTestPull)
	cmdSubscribeTestQueue.Flags().IntVar(&numPubsub, "pubsub", 2, "Number of pubsub subscriber")
	cmdSubscribeTestQueue.Flags().IntVar(&numQueue, "queue", 2, "Number of queue subscriber")
	cmdSubscribeTestQueue.Flags().DurationVar(&interval, "interval", 100*time.Millisecond, "Publish interval")
	cmdSubscribeTestQueue.Flags().DurationVar(&duration, "duration", 3*time.Second, "Publish duration")
	cmdSubscribe.AddCommand(cmdSubscribeTestQueue)

	cmdSubscribe.Flags().IntVar(&subIntervalCount, "interval", 1, "Subscribe print receive message interval count. Used to avoid excessive print message by skipping this count number.")
	rootCmd.AddCommand(cmdSubscribe)
}

func runSubscribe(cmd *cobra.Command, args []string) {
	config, err := configInit(cmd)
	if err != nil {
		log.Fatalf("configInit() error: %v", err)
	}
	subject := args[0]
	// connect to NATS
	natsConn, err := natsConnect(config)
	if err != nil {
		log.Fatalf("Connect() error: %v", err)
	}
	defer natsConn.Close()
	// publish message
	count := 0
	_, err = natsConn.Subscribe(subject, func(msg *nats.Msg) {
		if count%subIntervalCount == 0 {
			log.Printf("[%v] %q", msg.Subject, string(msg.Data))
		}
		count++
	})
	if err != nil {
		log.Fatalf("Subscribe() error: %v", err)
	}
	// wait receiving till break
	sigs := make(chan os.Signal, 1)
	done := make(chan bool, 1)
	signal.Notify(sigs, syscall.SIGINT, syscall.SIGTERM)
	go func() {
		<-sigs
		fmt.Println()
		done <- true
	}()
	log.Println("Awaiting NATS message...")
	<-done
	log.Println("Exit NATS receive message.")
}

// TestMessage is a message that can help test timings on jetstream
type TestMessage struct {
	ID          int       `json:"id"`
	PublishTime time.Time `json:"publish_time"`
}

func runSubscribeTestPull(cmd *cobra.Command, args []string) {
	config, err := configInit(cmd)
	if err != nil {
		log.Fatalf("configInit() error: %v", err)
	}
	// connect to NATS
	nc, err := natsConnect(config)
	if err != nil {
		log.Fatalf("Connect() error: %v", err)
	}
	defer nc.Close()

	stream := uuid.NewV4().String()
	// subject := fmt.Sprintf("%s-bar", id)
	subject := stream

	js, err := nc.JetStream()
	if err != nil {
		log.Fatalf("error getting jetstream: %v", err)
	}

	info, err := js.StreamInfo(stream)
	if err == nil {
		log.Fatalf("Stream already exists: %v", info)
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	_, err = js.AddStream(&nats.StreamConfig{
		Name:      stream,
		Subjects:  []string{subject},
		Retention: nats.WorkQueuePolicy,
	}, nats.Context(ctx))
	if err != nil {
		log.Fatalf("can't add: %v", err)
	}

	// Our resulting use measurements
	results := make(chan int64)

	var totalTime int64

	var totalMessages int64

	go func() {
		err := sub(ctx, config, subject, results)
		if err != nil {
			log.Fatalf("%v", err)
		}
	}()

	go func() {
		err := sub(ctx, config, subject, results)
		if err != nil {
			log.Fatalf("%v", err)
		}
	}()

	// our publisher thread
	go func() {
		i := 0

		for {
			start := time.Now()

			bytes, err := json.Marshal(&TestMessage{
				ID:          i,
				PublishTime: start,
			})
			if err != nil {
				log.Fatalf("could not get bytes from literal TestMessage... %v", err)
			}

			_, err = js.Publish(subject, bytes, nats.Context(ctx))
			if err != nil {
				if errors.Is(err, context.DeadlineExceeded) {
					return
				}

				log.Printf("error publishing: %v", err)
			}

			log.Printf("[publisher] sent %d, publish time usec: %d", i, time.Since(start).Microseconds())
			time.Sleep(1 * time.Second)

			i++
		}
	}()

	for {
		select {
		case <-ctx.Done():
			cancel()
			log.Printf("sent %d messages with average time of %f", totalMessages, math.Round(float64(totalTime/totalMessages)))
			js.DeleteStream(stream)
			return
		case usec := <-results:
			totalTime += usec
			totalMessages++
		}
	}
}

func sub(ctx context.Context, config *Configuration, subject string, results chan int64) error {
	id := uuid.NewV4().String()

	nc, err := natsConnect(config)
	if err != nil {
		log.Fatalf("[%s] unable to connect to nats: %v", id, err)
	}

	var js nats.JetStream

	js, err = nc.JetStream()
	if err != nil {
		return err
	}

	sub, err := js.PullSubscribe(subject, "group")
	if err != nil {
		return err
	}

	for {
		msgs, err := sub.Fetch(1, nats.Context(ctx))
		if err != nil {
			if errors.Is(err, context.DeadlineExceeded) {
				break
			}

			log.Printf("[consumer: %s] error consuming, sleeping for a second: %v", id, err)
			time.Sleep(1 * time.Second)

			continue
		}
		msg := msgs[0]

		var tMsg *TestMessage

		err = json.Unmarshal(msg.Data, &tMsg)
		if err != nil {
			log.Printf("[consumer: %s] error consuming, sleeping for a second: %v", id, err)
			time.Sleep(1 * time.Second)

			continue
		}

		tm := time.Since(tMsg.PublishTime).Microseconds()
		results <- tm

		log.Printf("[consumer: %s] received msg (%d) after waiting usec: %d", id, tMsg.ID, tm)

		err = msg.Ack(nats.Context(ctx))
		if err != nil {
			log.Printf("[consumer: %s] error acking message: %v", id, err)
		}

	}

	return nil
}

func runSubscribeTestQueue(cmd *cobra.Command, args []string) {
	config, err := configInit(cmd)
	if err != nil {
		log.Fatalf("configInit() error: %v", err)
	}
	// connect to NATS
	nc, err := natsConnect(config)
	if err != nil {
		log.Fatalf("Connect() error: %v", err)
	}
	defer nc.Close()

	stream := args[0]
	subject := args[1]
	// deliverSubject := stream + "Deliver"

	js, err := nc.JetStream()
	if err != nil {
		log.Fatalf("error getting jetstream: %v", err)
	}
	_, err = js.AddStream(&nats.StreamConfig{
		Name:     stream,
		Subjects: []string{subject},
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
				subject,
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
			_, err = js.Publish(subject, []byte(msg))
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
	log.Printf("broker create push-based consumer %v > %v with filter %q; message will then be delivered to subject %v group %v", stream, consumer, filter, deliverSubject, deliverGroup)
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
