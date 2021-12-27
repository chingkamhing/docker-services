package main

import (
	"fmt"
	"log"
	"os"

	mqtt "github.com/eclipse/paho.mqtt.golang"
)

var messagePubHandler mqtt.MessageHandler = func(client mqtt.Client, msg mqtt.Message) {
	log.Printf("Received message: %s from topic: %s\n", msg.Payload(), msg.Topic())
}

var connectHandler mqtt.OnConnectHandler = func(client mqtt.Client) {
	log.Printf("Connected")
}

var connectLostHandler mqtt.ConnectionLostHandler = func(client mqtt.Client, err error) {
	log.Printf("Connect lost: %v", err)
}

const broker = "127.0.0.1"
const port = 1883
const clientID = "go_mqtt_client"
const username = "my_mqtt_user"
const password = "eyJ0eXAiOiJKV1QiLCJhbGciOiJlZDI1NTE5LW5rZXkifQ.eyJqdGkiOiJERzc2RjI0Rjc3QkgyWkJUMkZQUDdXQ0RaU1VVVTRRNzY1SzdHV0pBTUZXMlNMQ0xSMkpRIiwiaWF0IjoxNjQwNTk4MDE1LCJpc3MiOiJBQlQ0RU40NUgzNU4zWDVFTk1MSkRXTkpKT05FMlpHN0ZXUFhJNENaSVM3UDY2RElDVkNXR01ZSSIsIm5hbWUiOiJNcXR0VXNlciIsInN1YiI6IlVCQVczNkZCUE9ZNkM0TFlDTDdUWUQ0WUpQSzdZVE43WkNYRzRTWE1RSUJTUlFLTjI2UDJUV1FUIiwibmF0cyI6eyJwdWIiOnt9LCJzdWIiOnt9LCJzdWJzIjotMSwiZGF0YSI6LTEsInBheWxvYWQiOi0xLCJiZWFyZXJfdG9rZW4iOnRydWUsInR5cGUiOiJ1c2VyIiwidmVyc2lvbiI6Mn19.90Vr4s0dRc7zUFF9skSWuJXIvk1rTX5cGE7dRBFIoiU_9XSFLWqibU0PH-xlof2pOXnNeKaV0g4JU42t8uCiDw"

func main() {
	log.Printf("mqtt")
	mqtt.DEBUG = log.New(os.Stdout, "", 0)
	mqtt.ERROR = log.New(os.Stdout, "", 0)
	opts := mqtt.NewClientOptions()
	opts.AddBroker(fmt.Sprintf("tcp://%s:%d", broker, port))
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
}
