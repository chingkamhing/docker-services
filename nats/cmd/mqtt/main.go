package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"time"

	mqtt "github.com/eclipse/paho.mqtt.golang"
)

var messagePubHandler mqtt.MessageHandler = func(client mqtt.Client, msg mqtt.Message) {
	log.Printf("Received message: %s from topic: %s", msg.Payload(), msg.Topic())
}

var connectHandler mqtt.OnConnectHandler = func(client mqtt.Client) {
	log.Printf("Connected")
}

var connectLostHandler mqtt.ConnectionLostHandler = func(client mqtt.Client, err error) {
	log.Printf("Connect lost: %v", err)
}

var host string
var port int
var clientID string
var username string
var password string
var topic string
var qos int
var retained bool
var count int
var interval time.Duration

func main() {
	// flags
	flag.StringVar(&host, "host", "127.0.0.1", "MQTT broker host address")
	flag.IntVar(&port, "port", 1883, "MQTT broker port number")
	flag.StringVar(&clientID, "id", "my_mqtt_client", "MQTT client ID")
	flag.StringVar(&username, "username", "mqtt_user", "MQTT client connection username")
	flag.StringVar(&password, "password", "", "MQTT client connection password")
	flag.StringVar(&topic, "topic", "test/msg", "MQTT publish/subscribe topic")
	flag.IntVar(&count, "count", 5, "MQTT publish loop count")
	flag.IntVar(&qos, "qos", 0, "MQTT qos of 0, 1 or 2")
	flag.BoolVar(&retained, "retained", false, "MQTT message retained in broker")
	flag.DurationVar(&interval, "interval", 1*time.Second, "MQTT publish loop interval")
	flag.Parse()
	log.Printf("mqtt")
	// connect mqtt
	mqtt.DEBUG = log.New(os.Stdout, "", 0)
	mqtt.ERROR = log.New(os.Stdout, "", 0)
	opts := mqtt.NewClientOptions()
	opts.AddBroker(fmt.Sprintf("tcp://%s:%d", host, port))
	opts.SetClientID(clientID)
	opts.SetUsername(username)
	opts.SetPassword(password)
	opts.SetDefaultPublishHandler(messagePubHandler)
	opts.OnConnect = connectHandler
	opts.OnConnectionLost = connectLostHandler
	client := mqtt.NewClient(opts)
	token := client.Connect()
	if token.Wait() && token.Error() != nil {
		panic(token.Error())
	}
	// mqtt publish messages to topic
	for i := 0; i < count; i++ {
		log.Printf("publish msg: %v", i)
		message := fmt.Sprintf("MQTT message #%d", i)
		token := client.Publish(topic, qos, retained, message)
		fmt.Println("publish msg: ", message)
		token.Wait()
		time.Sleep(interval)
	}
}
