package cmd

import (
	"fmt"
	"log"
	"os"
	"os/signal"
	"syscall"

	"github.com/nats-io/nats.go"
	"github.com/spf13/cobra"
)

var cmdSubscribe = &cobra.Command{
	Use:   "sub [subject]",
	Short: "Core NATS subscribe related sub-commands",
	Args:  cobra.ExactArgs(1),
	Run:   runSubscribe,
}

func init() {
	cmdSubscribe.Flags().IntVar(&subIntervalCount, "interval", 1, "Subscribe print receive message interval count. Used to avoid excessive print message by skipping this count number.")
	rootCmd.AddCommand(cmdSubscribe)
}

func runSubscribe(cmd *cobra.Command, args []string) {
	config, err := configInit(cmd)
	if err != nil {
		log.Fatalf("configInit() error: %v", err)
	}
	subject := args[0]
	// connect to NATS
	natsConn, err := natsConnect(config)
	if err != nil {
		log.Fatalf("Connect() error: %v", err)
	}
	defer natsConn.Close()
	// publish message
	count := 0
	_, err = natsConn.Subscribe(subject, func(msg *nats.Msg) {
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
	log.Println("Awaiting NATS message...")
	<-done
	log.Println("Exit NATS receive message.")
}
