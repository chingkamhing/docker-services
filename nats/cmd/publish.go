package cmd

import (
	"log"

	"github.com/spf13/cobra"
)

var cmdPublish = &cobra.Command{
	Use:   "pub [subject] [message]",
	Short: "Publish NATS message",
	Args:  cobra.ExactArgs(2),
	Run:   runPublish,
}

func init() {
	rootCmd.AddCommand(cmdPublish)
}

func runPublish(cmd *cobra.Command, args []string) {
	config, err := configInit(cmd)
	if err != nil {
		log.Fatalf("configInit() error: %v", err)
	}
	subject := args[0]
	message := args[1]
	// connect to NATS
	natsConn, err := natsConnect(config)
	if err != nil {
		log.Fatalf("Connect() error: %v", err)
	}
	defer natsConn.Close()
	// publish message
	err = natsConn.Publish(subject, []byte(message))
	if err != nil {
		log.Fatalf("Publish() error: %v", err)
	}
	log.Printf("Published %q to %q", message, subject)
}
