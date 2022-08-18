package cmd

import (
	"log"
	"os"
	"testing"
	"time"
)

var mqttConfig = &Configuration{
	Mqtt: Mqtt{
		Host:         "127.0.0.1",
		Port:         1883,
		CaFilename:   "../cert/my-domain.com/ca.crt",
		CertFilename: "../cert/my-domain.com/client.crt",
		KeyFilename:  "../cert/my-domain.com/client.key",
		Username:     os.Getenv("MY_MQTT_USERNAME"),
		Password:     os.Getenv("MY_MQTT_PASSWORD"),
		Log:          "ERROR",
		ClientID:     "mqtt-test",
		KeepAlive:    60 * time.Second,
		Qos:          0,
		Retained:     false,
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
	const subject = "my-test/mqtt"
	const message = "MQTT test 0 message."
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
	const subject = "my-test/mqtt"
	const message = "MQTT test 1 message."
	for n := 0; n < b.N; n++ {
		client.Publish(subject, byte(mqttConfig.Mqtt.Qos), mqttConfig.Mqtt.Retained, message)
	}
}
