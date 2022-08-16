package cmd

import (
	"fmt"
	"io"
	"log"
	"net"
	"net/url"
	"os"
	"os/signal"
	"strconv"
	"syscall"
	"time"

	"github.com/spf13/cobra"

	mqtt "github.com/eclipse/paho.mqtt.golang"
)

var cmdMqtt = &cobra.Command{
	Use:   "mqtt",
	Short: "MQTT related sub-commands",
	Run: func(cmd *cobra.Command, args []string) {
		_ = args
		// default command: print usage
		cmd.Usage()
	},
}

var cmdMqttPub = &cobra.Command{
	Use:   "pub [subject] [message]",
	Short: "MQTT publish message",
	Args:  cobra.ExactArgs(2),
	Run:   runMqttPub,
}

var cmdMqttSub = &cobra.Command{
	Use:   "sub [subject]",
	Short: "MQTT subscribe message",
	Args:  cobra.ExactArgs(1),
	Run:   runMqttSub,
}

var cmdMqttTest = &cobra.Command{
	Use:   "test [subject]",
	Short: "Test MQTT publish and subscribe message",
	Args:  cobra.ExactArgs(1),
	Run:   runMqttTest,
}

func init() {
	cmdMqtt.AddCommand(cmdMqttPub)
	cmdMqttSub.Flags().IntVar(&subIntervalCount, "interval", 1, "Subscribe print receive message interval count. Used to avoid excessive print message by skipping this count number.")
	cmdMqtt.AddCommand(cmdMqttSub)
	cmdMqtt.AddCommand(cmdMqttTest)

	cmdMqtt.PersistentFlags().String("mqtt.host", "127.0.0.1", "MQTT connection host address")
	cmdMqtt.PersistentFlags().Int("mqtt.port", 1883, "MQTT connection port number")
	cmdMqtt.PersistentFlags().String("mqtt.username", "", "MQTT connection username")
	cmdMqtt.PersistentFlags().String("mqtt.password", "", "MQTT connection password")
	cmdMqtt.PersistentFlags().String("mqtt.log", "ERROR", "MQTT log level of: DEBUG, ERROR")
	cmdMqtt.PersistentFlags().String("mqtt.id", "my_mqtt_client", "MQTT client ID")
	cmdMqtt.PersistentFlags().Duration("mqtt.alive", 60*time.Second, "MQTT keep alive time")
	cmdMqtt.PersistentFlags().Int("mqtt.count", 5, "MQTT publish loop count")
	cmdMqtt.PersistentFlags().Int("mqtt.qos", 0, "MQTT qos of 0, 1 or 2")
	cmdMqtt.PersistentFlags().Bool("mqtt.retained", false, "MQTT message retained in broker")
	cmdMqtt.PersistentFlags().Duration("mqtt.interval", 1*time.Second, "MQTT publish loop interval")
	rootCmd.AddCommand(cmdMqtt)
}

func runMqttPub(cmd *cobra.Command, args []string) {
	config, err := configInit(cmd)
	if err != nil {
		log.Fatalf("configInit() error: %v", err)
	}
	// connect mqtt
	client, err := mqttConnect(config)
	if err != nil {
		log.Fatalf("mqttConnect() error: %v", err)
	}
	defer func() {
		client.Disconnect(250)
	}()
	// mqtt publish messages to subject
	subject := args[0]
	message := args[1]
	token := client.Publish(subject, byte(config.Mqtt.Qos), config.Mqtt.Retained, message)
	log.Printf("Published [%v] %q", subject, message)
	token.Wait()
}

func runMqttSub(cmd *cobra.Command, args []string) {
	config, err := configInit(cmd)
	if err != nil {
		log.Fatalf("configInit() error: %v", err)
	}
	// connect mqtt
	client, err := mqttConnect(config)
	if err != nil {
		log.Fatalf("mqttConnect() error: %v", err)
	}
	defer func() {
		client.Disconnect(250)
	}()
	// mqtt subscribe to subject
	subject := args[0]
	count := 0
	token := client.Subscribe(subject, byte(config.Mqtt.Qos), func(client mqtt.Client, msg mqtt.Message) {
		if count%subIntervalCount == 0 {
			log.Printf("[%v] %q", msg.Topic(), string(msg.Payload()))
		}
		count++
	})
	if token.Wait() && token.Error() != nil {
		log.Fatalf("client.Subscribe() error: %v", token.Error())
	}
	// wait receiving till break
	sigs := make(chan os.Signal, 1)
	done := make(chan bool, 1)
	signal.Notify(sigs, syscall.SIGINT, syscall.SIGTERM)
	go func() {
		<-sigs
		fmt.Println()
		done <- true
	}()
	log.Println("Awaiting MQTT message...")
	<-done
	log.Println("Exit MQTT receive message.")
}

func runMqttTest(cmd *cobra.Command, args []string) {
	config, err := configInit(cmd)
	if err != nil {
		log.Fatalf("configInit() error: %v", err)
	}
	// connect mqtt
	client, err := mqttConnect(config)
	if err != nil {
		log.Fatalf("mqttConnect() error: %v", err)
	}
	// mqtt subscribe to topic
	subject := args[0]
	token := client.Subscribe(subject, byte(config.Mqtt.Qos), func(client mqtt.Client, msg mqtt.Message) {
		log.Printf("Received from %q: %v", msg.Topic(), string(msg.Payload()))
	})
	if token.Wait() && token.Error() != nil {
		log.Fatalf("client.Subscribe() error: %v", token.Error())
	}
	// mqtt publish messages to topic
	for i := 0; i < config.Mqtt.Count; i++ {
		log.Printf("publish msg: %v", i)
		message := fmt.Sprintf("MQTT message #%d", i)
		token := client.Publish(subject, byte(config.Mqtt.Qos), config.Mqtt.Retained, message)
		log.Printf("publish msg: %v", message)
		token.Wait()
		time.Sleep(config.Mqtt.Interval)
	}
	// disconnect
	client.Disconnect(250)
	time.Sleep(1 * time.Second)
}

func mqttConnect(config *Configuration) (mqtt.Client, error) {
	if config.Mqtt.Log == "DEBUG" {
		mqtt.DEBUG = log.New(os.Stdout, "DEBUG ", 0)
	} else {
		mqtt.DEBUG = log.New(io.Discard, "", 0)
	}
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
		return nil, fmt.Errorf("client.Connect(): %w", token.Error())
	}
	return client, nil
}

var messagePubHandler mqtt.MessageHandler = func(client mqtt.Client, msg mqtt.Message) {
	log.Printf("Published MQTT message %q to %q", msg.Payload(), msg.Topic())
}

var connectHandler mqtt.OnConnectHandler = func(client mqtt.Client) {
	log.Printf("MQTT connected")
}

var connectLostHandler mqtt.ConnectionLostHandler = func(client mqtt.Client, err error) {
	log.Printf("MQTT connect lost: %v", err)
}
