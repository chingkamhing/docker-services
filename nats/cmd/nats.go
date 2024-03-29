package cmd

import (
	"fmt"
	"log"
	"os"
	"os/signal"
	"syscall"

	"github.com/nats-io/nats.go"
	"github.com/nats-io/nkeys"
	"github.com/spf13/cobra"
)

var cmdNats = &cobra.Command{
	Use:   "nats",
	Short: "Core NATS related sub-commands",
	Run: func(cmd *cobra.Command, args []string) {
		_ = args
		// default command: print usage
		cmd.Usage()
	},
}

var cmdNatsPublish = &cobra.Command{
	Use:   "pub [subject] [message]",
	Short: "Publish core NATS message",
	Args:  cobra.ExactArgs(2),
	Run:   runNatsPublish,
}

var cmdNatsSubscribe = &cobra.Command{
	Use:   "sub [subject]",
	Short: "Core NATS subscribe related sub-commands",
	Args:  cobra.ExactArgs(1),
	Run:   runNatsSubscribe,
}

func init() {
	cmdNats.AddCommand(cmdNatsPublish)
	cmdNatsSubscribe.Flags().IntVar(&subIntervalCount, "interval", 1, "Subscribe print receive message interval count. Used to avoid excessive print message by skipping this count number.")
	cmdNats.AddCommand(cmdNatsSubscribe)

	rootCmd.AddCommand(cmdNats)
}

func runNatsPublish(cmd *cobra.Command, args []string) {
	config, err := configInit(cmd)
	if err != nil {
		log.Fatalf("configInit() error: %v", err)
	}
	subject := args[0]
	message := args[1]
	// connect to NATS
	nc, err := natsConnect(config)
	if err != nil {
		log.Fatalf("Connect() error: %v", err)
	}
	defer nc.Close()
	// publish message
	err = nc.Publish(subject, []byte(message))
	if err != nil {
		log.Fatalf("Publish() error: %v", err)
	}
	log.Printf("Published [%v] %q", subject, message)
}

func runNatsSubscribe(cmd *cobra.Command, args []string) {
	config, err := configInit(cmd)
	if err != nil {
		log.Fatalf("configInit() error: %v", err)
	}
	subject := args[0]
	// connect to NATS
	nc, err := natsConnect(config)
	if err != nil {
		log.Fatalf("Connect() error: %v", err)
	}
	defer nc.Close()
	// publish message
	count := 0
	_, err = nc.Subscribe(subject, func(msg *nats.Msg) {
		if count%subIntervalCount == 0 {
			log.Printf("[%v] %q", msg.Subject, string(msg.Data))
		}
		count++
	})
	if err != nil {
		log.Fatalf("Subscribe() error: %v", err)
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
	log.Printf("Awaiting NATS core message from subject %q...", subject)
	<-done
	log.Println("Exit NATS receive message.")
}

func natsConnect(config *Configuration) (*nats.Conn, error) {
	opts := []nats.Option{}
	// set nats authentication options
	switch {
	case config.Nats.Username != "" && config.Nats.Password != "":
		opts = append(opts, nats.UserInfo(config.Nats.Username, config.Nats.Password))
	case config.Nats.NkeyUser != "" && config.Nats.NkeySeed != "":
		opts = append(opts, nats.Nkey(config.Nats.NkeyUser, func(nounce []byte) ([]byte, error) {
			keyPair, err := nkeys.FromSeed([]byte(config.Nats.NkeySeed))
			if err != nil {
				log.Fatalf("FromSeed() error: %v", err)
			}
			return keyPair.Sign(nounce)
		}))
	}
	// set tls connect options
	switch {
	case config.Nats.CaFilename != "" && config.Nats.CertFilename != "" && config.Nats.KeyFilename != "":
		tlsConfig, err := loadTlsConfig(config.Nats.CaFilename, config.Nats.CertFilename, config.Nats.KeyFilename, config.Nats.Insecure)
		if err != nil {
			return nil, fmt.Errorf("loadTlsConfig(): %w", err)
		}
		opts = append(opts, nats.Secure(tlsConfig))
	case config.Nats.CertFilename != "" && config.Nats.KeyFilename != "":
		opts = append(opts, nats.ClientCert(config.Nats.CertFilename, config.Nats.KeyFilename))
	case config.Nats.CaFilename != "":
		opts = append(opts, nats.RootCAs(config.Nats.CaFilename))
	}
	// connect nats
	nc, err := nats.Connect(config.Nats.Url, opts...)
	if err != nil {
		return nil, fmt.Errorf("natsConnect(): %w", err)
	}
	return nc, nil
}
