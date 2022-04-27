package main

import (
	"context"
	"errors"
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
const interval = 100 * time.Millisecond
const duration = 3 * time.Second

var username = os.Getenv("NATS_USERNAME")
var password = os.Getenv("NATS_PASSWORD")

func init() {
	log.SetFlags(0)
}

func main() {
	stream := os.Args[1]
	topic := os.Args[2]
	queue := stream + "Queue"
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
		_, err = js.Subscribe(
			topic,
			func(m *nats.Msg) {
				log.Printf("Sub 1: %s", m.Data)
			},
			opts...,
		)
		_, err = js.Subscribe(
			topic,
			func(m *nats.Msg) {
				log.Printf("Sub 2: %s", m.Data)
			},
			opts...,
		)
	}
	{
		opts := []nats.SubOpt{
			nats.AckExplicit(),
			nats.DeliverNew(),
		}
		_, err = js.QueueSubscribe(
			topic,
			queue,
			func(m *nats.Msg) {
				log.Printf("Queue 1: %s", m.Data)
			},
			opts...,
		)
		_, err = js.QueueSubscribe(
			topic,
			queue,
			func(m *nats.Msg) {
				log.Printf("Queue 2: %s", m.Data)
			},
			opts...,
		)
	}

	// our publisher thread
	ctx, cancel := context.WithTimeout(context.Background(), duration)
	defer cancel()
	go func() {
		for i := 0; i < math.MaxInt; i++ {
			msg := fmt.Sprintf(`{"key": "%d"}`, i)
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
