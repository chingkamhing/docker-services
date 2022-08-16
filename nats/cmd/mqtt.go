package cmd

import (
	"fmt"
	"log"
	"net"
	"net/url"
	"os"
	"strconv"
	"time"

	"github.com/spf13/cobra"

	mqtt "github.com/eclipse/paho.mqtt.golang"
)

var cmdMqtt = &cobra.Command{
	Use:   "mqtt",
	Short: "iTMS mongodb related sub-commands",
	Run: func(cmd *cobra.Command, args []string) {
		_ = args
		// default command: print usage
		cmd.Usage()
	},
}

var cmdMqttTest = &cobra.Command{
	Use:   "test",
	Short: "Test MQTT publish and subscribe message",
	Args:  cobra.ExactArgs(0),
	Run:   runMqttTest,
}

func init() {
	cmdMqttTest.Flags().String("mqtt.host", "127.0.0.1", "MQTT connection host address")
	cmdMqttTest.Flags().Int("mqtt.port", 1883, "MQTT connection port number")
	cmdMqttTest.Flags().String("mqtt.username", "", "MQTT connection username")
	cmdMqttTest.Flags().String("mqtt.password", "", "MQTT connection password")
	cmdMqttTest.Flags().String("mqtt.id", "my_mqtt_client", "MQTT client ID")
	cmdMqttTest.Flags().Duration("mqtt.alive", 60*time.Second, "MQTT keep alive time")
	cmdMqttTest.Flags().String("mqtt.topic", "test/msg", "MQTT publish/subscribe topic")
	cmdMqttTest.Flags().Int("mqtt.count", 5, "MQTT publish loop count")
	cmdMqttTest.Flags().Int("mqtt.qos", 0, "MQTT qos of 0, 1 or 2")
	cmdMqttTest.Flags().Bool("mqtt.retained", false, "MQTT message retained in broker")
	cmdMqttTest.Flags().Duration("mqtt.interval", 1*time.Second, "MQTT publish loop interval")
	cmdMqtt.AddCommand(cmdMqttTest)

	rootCmd.AddCommand(cmdMqtt)
}

func runMqttTest(cmd *cobra.Command, args []string) {
	_ = args
	config, err := configInit(cmd)
	if err != nil {
		log.Fatalf("configInit() error: %v", err)
	}
	// connect mqtt
	mqtt.DEBUG = log.New(os.Stdout, "DEBUG ", 0)
	mqtt.ERROR = log.New(os.Stdout, "ERROR ", 0)
	opts := mqtt.NewClientOptions()
	u, _ := url.Parse("")
	u.Scheme = "tcp"
	u.Host = net.JoinHostPort(config.Mqtt.Host, strconv.Itoa(config.Mqtt.Port))
	opts.AddBroker(u.String())
	opts.SetClientID(config.Mqtt.ClientID)
	opts.SetUsername(config.Mqtt.Username)
	opts.SetPassword(config.Mqtt.Password)
	opts.SetDefaultPublishHandler(messagePubHandler)
	opts.SetKeepAlive(config.Mqtt.KeepAlive)
	opts.OnConnect = connectHandler
	opts.OnConnectionLost = connectLostHandler
	client := mqtt.NewClient(opts)
	token := client.Connect()
	if token.Wait() && token.Error() != nil {
		log.Fatalf("client.Connect() error: %v", token.Error())
	}
	// mqtt subscribe to topic
	token = client.Subscribe(config.Mqtt.Topic, byte(config.Mqtt.Qos), receiveHandler)
	if token.Wait() && token.Error() != nil {
		log.Fatalf("client.Subscribe() error: %v", token.Error())
	}
	// mqtt publish messages to topic
	for i := 0; i < config.Mqtt.Count; i++ {
		log.Printf("publish msg: %v", i)
		message := fmt.Sprintf("MQTT message #%d", i)
		token := client.Publish(config.Mqtt.Topic, byte(config.Mqtt.Qos), config.Mqtt.Retained, message)
		log.Printf("publish msg: %v", message)
		token.Wait()
		time.Sleep(config.Mqtt.Interval)
	}
	// disconnect
	client.Disconnect(250)
	time.Sleep(1 * time.Second)
}

var messagePubHandler mqtt.MessageHandler = func(client mqtt.Client, msg mqtt.Message) {
	log.Printf("Received message: %s from topic: %s", msg.Payload(), msg.Topic())
}

var connectHandler mqtt.OnConnectHandler = func(client mqtt.Client) {
	log.Printf("Connected")
}

var connectLostHandler mqtt.ConnectionLostHandler = func(client mqtt.Client, err error) {
	log.Printf("Connect lost: %v", err)
}

var receiveHandler mqtt.MessageHandler = func(client mqtt.Client, msg mqtt.Message) {
	log.Printf("Received from %q: %v", msg.Topic(), string(msg.Payload()))
}
