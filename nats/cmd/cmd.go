package cmd

import (
	"log"
	"time"

	"github.com/spf13/cobra"
)

// service root cli command settings
var rootCmd = &cobra.Command{
	Use:   "",
	Short: "NATS test functions",
	Run: func(cmd *cobra.Command, args []string) {
		_ = args
		// default command: print usage
		cmd.Usage()
	},
}

func init() {
	// database config flags
	rootCmd.PersistentFlags().String("nats.url", "127.0.0.1:4222", "NATS broker host address")
	rootCmd.PersistentFlags().String("nats.ca_filename", "", "NATS TLS CA filename")
	rootCmd.PersistentFlags().String("nats.cert_filename", "", "NATS TLS cert filename")
	rootCmd.PersistentFlags().String("nats.key_filename", "", "NATS TLS key filename")
	rootCmd.PersistentFlags().Bool("nats.insecure", false, "NATS TLS not verifies the server's certificate")
	rootCmd.PersistentFlags().String("nats.nkey_user", "", "NATS connection nkey user")
	rootCmd.PersistentFlags().String("nats.nkey_seed", "", "NATS connection nkey seed")
	rootCmd.PersistentFlags().String("nats.username", "", "NATS client connection username")
	rootCmd.PersistentFlags().String("nats.password", "", "NATS client connection password")
	rootCmd.PersistentFlags().Int("nats.retry", 10, "NATS connection retry max count")
	rootCmd.PersistentFlags().Duration("nats.retry_interval", 3*time.Second, "NATS connection retry interval")
	rootCmd.PersistentFlags().String("nats.stream", "my-test-stream", "NATS stream name")
	rootCmd.PersistentFlags().String("nats.topics", "my-test.>", "comma-seperated NATS stream topics")
	rootCmd.InitDefaultVersionFlag()
}

// Execute init cli commands, flags and read configuration
func Execute() {
	// run root command
	err := rootCmd.Execute()
	if err != nil {
		log.Println(err)
	}
}
