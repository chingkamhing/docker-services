package cmd

import (
	"log"
	"os"
	"testing"
	"time"

	"github.com/nats-io/nats.go"
)

var natsConfig = &Configuration{
	Nats: Nats{
		Url:           "127.0.0.1:4222",
		CaFilename:    "../cert/my-domain.com/ca.crt",
		CertFilename:  "../cert/my-domain.com/client.crt",
		KeyFilename:   "../cert/my-domain.com/client.key",
		Username:      os.Getenv("MY_LEAF_USERNAME"),
		Password:      os.Getenv("MY_LEAF_PASSWORD"),
		Retry:         3,
		RetryInterval: 2 * time.Second,
		Stream:        "my-test-stream",
		Topics:        "my-test.>",
	},
}

func Benchmark_NatsPublish(b *testing.B) {
	// connect NATS
	nc, err := natsConnect(natsConfig)
	if err != nil {
		log.Fatalf("natsConnect() error: %v", err)
	}
	defer nc.Close()
	// nats publish messages to subject
	const subject = "my-test.nats"
	const message = "NATS test 0 message."
	for n := 0; n < b.N; n++ {
		nc.Publish(subject, []byte(message))
	}
}

func Benchmark_JetstreamPublish(b *testing.B) {
	// connect NATS
	js, nc, err := jetstreamConnect(natsConfig)
	if err != nil {
		log.Fatalf("jetstreamConnect() error: %v", err)
	}
	defer nc.Close()
	// nats publish messages to subject
	const subject = "my-test.jets"
	const message = "JetS test 0 message."
	msg := nats.NewMsg(subject)
	for n := 0; n < b.N; n++ {
		msg.Data = []byte(message)
		js.PublishMsg(msg)
	}
}
