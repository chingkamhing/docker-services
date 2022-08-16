package cmd

import (
	"log"
	"os"
	"testing"
	"time"
)

var natsConfig = &Configuration{
	Nats: Nats{
		Url:           "127.0.0.1:4222",
		Username:      os.Getenv("MY_NATS_USERNAME"),
		Password:      os.Getenv("MY_NATS_PASSWORD"),
		Retry:         3,
		RetryInterval: 2 * time.Second,
	},
}

func Benchmark_NatsPublish(b *testing.B) {
	// connect NATS
	natsConn, err := natsConnect(natsConfig)
	if err != nil {
		log.Fatalf("natsConnect() error: %v", err)
	}
	defer func() {
		natsConn.Drain()
	}()
	// nats publish messages to subject
	const subject = "test.nats"
	const message = "NATS test message."
	for n := 0; n < b.N; n++ {
		natsConn.Publish(subject, []byte(message))
	}
}
