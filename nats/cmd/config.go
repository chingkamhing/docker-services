package cmd

import (
	"strings"
	"time"

	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

// default settings
const defaultEnvPrefix = "MY"

var config Configuration

type Configuration struct {
	Nats Nats
	Mqtt Mqtt
}

// Nats define all nats settings structure
type Nats struct {
	Url           string        `mapstructure:"url"`            // NATS system url (e.g. localhost:4222); comma seperate for multiple urls
	CaFilename    string        `mapstructure:"ca_filename"`    // NATS connection CA filename
	CertFilename  string        `mapstructure:"cert_filename"`  // NATS connection client cert filename
	KeyFilename   string        `mapstructure:"key_filename"`   // NATS connection client key filename
	NkeyUser      string        `mapstructure:"nkey_user"`      // NATS connection nkey user
	NkeySeed      string        `mapstructure:"nkey_seed"`      // NATS connection nkey seed
	Username      string        `mapstructure:"username"`       // NATS connection username
	Password      string        `mapstructure:"password"`       // NATS connection password
	Retry         int           `mapstructure:"retry"`          // NATS connection retry max count
	RetryInterval time.Duration `mapstructure:"retry_interval"` // NATS connection retry interval
	Stream        string        `mapstructure:"stream"`         // NATS stream name
	Topics        string        `mapstructure:"topics"`         // comma-seperated NATS stream topics
}

// Mqtt holds mqtt settings
type Mqtt struct {
	Host         string        `mapstructure:"host"`          // MQTT host address
	Port         int           `mapstructure:"port"`          // MQTT port number
	CaFilename   string        `mapstructure:"ca_filename"`   // MQTT connection CA filename
	CertFilename string        `mapstructure:"cert_filename"` // MQTT connection client cert filename
	KeyFilename  string        `mapstructure:"key_filename"`  // MQTT connection client key filename
	Username     string        `mapstructure:"username"`      // MQTT connection username
	Password     string        `mapstructure:"password"`      // MQTT connection password
	Log          string        `mapstructure:"log"`           // MQTT log level of: DEBUG, ERROR
	ClientID     string        `mapstructure:"client_id"`
	KeepAlive    time.Duration `mapstructure:"keep_alive"`
	Qos          int           `mapstructure:"qos"`
	Retained     bool          `mapstructure:"retained"`
	Count        int           `mapstructure:"count"`
	Interval     time.Duration `mapstructure:"interval"`
}

// configInit load config setting from file name stored in flag "config"
func configInit(cmd *cobra.Command) (*Configuration, error) {
	err := viper.BindPFlags(cmd.Flags())
	if err != nil {
		return nil, err
	}

	// get environment config
	viper.SetEnvPrefix(defaultEnvPrefix)
	viper.SetEnvKeyReplacer(strings.NewReplacer(".", "_"))
	viper.AutomaticEnv()

	// unmarshal the config file
	err = viper.Unmarshal(&config)
	if err != nil {
		return nil, err
	}
	return &config, nil
}
