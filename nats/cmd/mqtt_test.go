package cmd

import (
	"log"
	"os"
	"testing"
	"time"
)

var mqttConfig = &Configuration{
	Mqtt: Mqtt{
		Host:      "127.0.0.1",
		Port:      1883,
		Username:  os.Getenv("MY_MQTT_USERNAME"),
		Password:  os.Getenv("MY_MQTT_PASSWORD"),
		Log:       "ERROR",
		ClientID:  "mqtt-test",
		KeepAlive: 60 * time.Second,
		Qos:       0,
		Retained:  false,
	},
}

func Benchmark_MqttQos0Publish(b *testing.B) {
	mqttConfig.Mqtt.Qos = 0
	// connect mqtt
	client, err := mqttConnect(mqttConfig)
	if err != nil {
		log.Fatalf("mqttConnect() error: %v", err)
	}
	defer func() {
		client.Disconnect(1000)
	}()
	// mqtt publish messages to subject
	const subject = "test/mqtt"
	const message = "MQTT test message."
	for n := 0; n < b.N; n++ {
		client.Publish(subject, byte(mqttConfig.Mqtt.Qos), mqttConfig.Mqtt.Retained, message)
	}
}

func Benchmark_MqttQos1Publish(b *testing.B) {
	mqttConfig.Mqtt.Qos = 1
	// connect mqtt
	client, err := mqttConnect(mqttConfig)
	if err != nil {
		log.Fatalf("mqttConnect() error: %v", err)
	}
	defer func() {
		client.Disconnect(1000)
	}()
	// mqtt publish messages to subject
	const subject = "test/mqtt"
	const message = "MQTT test message."
	for n := 0; n < b.N; n++ {
		client.Publish(subject, byte(mqttConfig.Mqtt.Qos), mqttConfig.Mqtt.Retained, message)
	}
}
