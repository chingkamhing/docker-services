package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"net"
	"net/http"
	"os"
	"strings"
)

const version = "0.4"

var host string
var port int

type myInfo struct {
	Hostname string
	IPs      []string
	Headers  map[string]string
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
			log.Printf("addr: %v\n", addr)
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
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func main() {
	flag.StringVar(&host, "host", "", "whoami host name")
	flag.IntVar(&port, "port", 8000, "whoami host port")
	flag.Parse()

	log.Printf("%s %s\n", os.Args[0], version)
	http.HandleFunc("/", handler)
	addr := fmt.Sprintf("%s:%d", host, port)
	log.Printf("whoami listening http at %s\n", addr)
	err := http.ListenAndServe(addr, nil)
	if err != nil {
		log.Printf("ListenAndServe: %v", err)
	}
}
