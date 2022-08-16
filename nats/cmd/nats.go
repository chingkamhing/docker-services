package cmd

import (
	"fmt"
	"log"

	"github.com/nats-io/nats.go"
	"github.com/nats-io/nkeys"
)

func natsConnect(config *Configuration) (*nats.Conn, error) {
	opts := []nats.Option{}
	switch {
	case config.Nats.NkeyUser != "" && config.Nats.NkeySeed != "":
		// nkey connect
		opts = append(opts, nats.Nkey(config.Nats.NkeyUser, func(nounce []byte) ([]byte, error) {
			keyPair, err := nkeys.FromSeed([]byte(config.Nats.NkeySeed))
			if err != nil {
				log.Fatalf("FromSeed() error: %v", err)
			}
			return keyPair.Sign(nounce)
		}))
	case config.Nats.Username != "" && config.Nats.Password != "":
		// username/password connect
		opts = append(opts, nats.UserInfo(config.Nats.Username, config.Nats.Password))
	}
	natsConn, err := nats.Connect(config.Nats.Url, opts...)
	if err != nil {
		return nil, fmt.Errorf("natsConnect(): %w", err)
	}
	return natsConn, nil
}
