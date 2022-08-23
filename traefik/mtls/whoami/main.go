package main

import (
	"crypto/tls"
	"crypto/x509"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"log"
	"net"
	"net/http"
	"os"
	"strings"
)

//
// references:
// - https://zhimin-wen.medium.com/mutual-tls-through-a-reverse-proxy-da60430fefd
//

type myInfo struct {
	Hostname string
	IPs      []string
	Headers  map[string]string
}

var host = getenv("MY_HOST", "")
var port = getenv("MY_PORT", "1443")
var caFile = getenv("MY_CA_FILENAME", "")
var certFile = getenv("MY_CERT_FILENAME", "")
var keyFile = getenv("MY_KEY_FILENAME", "")

func main() {
	// parse flags
	flag.StringVar(&host, "host", host, "Server host")
	flag.StringVar(&port, "port", port, "Server port")
	flag.StringVar(&caFile, "ca", caFile, "mTLS CA filename")
	flag.StringVar(&certFile, "cert", certFile, "mTLS cert filename")
	flag.StringVar(&keyFile, "key", keyFile, "mTLS key filename")
	flag.Parse()
	// start server
	http.HandleFunc("/", handler)
	serveAddress := fmt.Sprintf("%s:%s", host, port)
	var err error
	if caFile == "" || certFile == "" || keyFile == "" {
		// serve http
		log.Printf("Listening on %v...", serveAddress)
		err = http.ListenAndServe(serveAddress, nil)
	} else {
		// serve https
		var tlsConfig *tls.Config
		tlsConfig, err = loadTlsConfig(caFile, certFile, keyFile)
		if err != nil {
			log.Fatalf("loadTlsConfig() error: %v", err)
		}
		server := &http.Server{
			Addr:      serveAddress,
			TLSConfig: tlsConfig,
		}
		log.Printf("Listening TLS on %v...", serveAddress)
		err = server.ListenAndServeTLS("", "")
	}
	if !errors.Is(err, http.ErrServerClosed) {
		log.Fatalf("server.ListenAndServeTLS() error: %v", err)
	}
}

func handler(w http.ResponseWriter, r *http.Request) {
	hostname, err := os.Hostname()
	if err != nil {
		http.Error(w, "Error hostname!", 500)
		return
	}
	ifaces, err := net.Interfaces()
	if err != nil {
		http.Error(w, "Error network interfaces!", 500)
		return
	}
	response := &myInfo{
		Hostname: hostname,
		Headers:  map[string]string{},
	}
	for _, iface := range ifaces {
		addrs, err := iface.Addrs()
		if err != nil {
			http.Error(w, "Error interface address!", 500)
			return
		}
		for _, addr := range addrs {
			var ip net.IP
			switch v := addr.(type) {
			case *net.IPNet:
				ip = v.IP
			case *net.IPAddr:
				ip = v.IP
			}
			response.IPs = append(response.IPs, ip.String())
		}
	}
	for name, headers := range r.Header {
		response.Headers[name] = strings.Join(headers, ",")
	}
	log.Printf("handle request from %v\n", r.RemoteAddr)
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

// load tls cert files
func loadTlsConfig(caFile, certFile, keyFile string) (*tls.Config, error) {
	certPool := x509.NewCertPool()
	if caFile != "" {
		ca, err := os.ReadFile(caFile)
		if err != nil {
			return nil, fmt.Errorf("os.ReadFile(): %w", err)
		}
		ok := certPool.AppendCertsFromPEM(ca)
		if !ok {
			return nil, fmt.Errorf("certPool.AppendCertsFromPEM(): %w", err)
		}
	}
	tlsPair, err := tls.LoadX509KeyPair(certFile, keyFile)
	if err != nil {
		return nil, fmt.Errorf("tls.LoadX509KeyPair(%v, %v): %w", certFile, keyFile, err)
	}
	tlsConfig := &tls.Config{
		ClientCAs:    certPool,
		Certificates: []tls.Certificate{tlsPair},
		ClientAuth:   tls.RequireAndVerifyClientCert,
	}
	return tlsConfig, nil
}

func getenv(env, fallback string) string {
	value := os.Getenv(env)
	if value == "" {
		value = fallback
	}
	return value
}
