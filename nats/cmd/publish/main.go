package main

import (
	"log"
	"sync"

	"github.com/nats-io/nats.go"
)

func main() {
	// Set a user and plain text password
	natsConn, err := nats.Connect("127.0.0.1", nats.UserCredentials("../../TestUser.creds"))
	if err != nil {
		log.Fatal(err)
	}
	defer natsConn.Close()

	// Do something with the connection
	log.Printf("natsConn.Status(): %v", natsConn.Status())
	log.Printf("natsConn.Stats(): %#v", natsConn.Stats())

	// Use a WaitGroup to wait for a message to arrive
	wg := sync.WaitGroup{}
	wg.Add(1)

	// Subscribe
	_, err = natsConn.Subscribe("test", testHandler(&wg))
	if err != nil {
		log.Fatal(err)
	}

	// Wait for a message to come in
	wg.Wait()
}

func testHandler(wg *sync.WaitGroup) nats.MsgHandler {
	return func(msg *nats.Msg) {
		log.Printf("data: %v", string(msg.Data))
		wg.Done()
	}
}
