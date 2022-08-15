package main

import (
	"flag"
	"log"
	"os"

	"github.com/nats-io/nats.go"
	"github.com/nats-io/nkeys"
)

var host string
var port int
var nkeyUser = os.Getenv("NATS_NKEY_USER")
var nkeySeed = os.Getenv("NATS_NKEY_SEED")
var username = os.Getenv("NATS_USERNAME")
var password = os.Getenv("NATS_PASSWORD")

func main() {
	// flags
	flag.StringVar(&host, "host", "127.0.0.1", "NATS broker host address")
	flag.IntVar(&port, "port", 1883, "NATS broker port number")
	flag.StringVar(&username, "username", username, "NATS client connection username")
	flag.StringVar(&password, "password", password, "NATS client connection password")
	flag.Parse()
	subject := flag.Args()[0]
	message := flag.Args()[1]
	// Set a user and plain text password
	opts := []nats.Option{}
	switch {
	case nkeyUser != "" && nkeySeed != "":
		opts = append(opts, nats.Nkey(nkeyUser, func(nounce []byte) ([]byte, error) {
			keyPair, err := nkeys.FromSeed([]byte(nkeySeed))
			if err != nil {
				log.Fatalf("FromSeed() error: %v", err)
			}
			return keyPair.Sign(nounce)
		}))
	case username != "" && password != "":
		opts = append(opts, nats.UserInfo(username, password))
	}
	natsConn, err := nats.Connect(host, opts...)
	if err != nil {
		log.Fatalf("Connect() error: %v", err)
	}
	defer natsConn.Close()
	// publish message
	err = natsConn.Publish(subject, []byte(message))
	if err != nil {
		log.Fatalf("Publish() error: %v", err)
	}
}
