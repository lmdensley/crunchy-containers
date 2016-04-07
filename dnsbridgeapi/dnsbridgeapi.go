package dnsbridgeapi

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	dockerapi "github.com/fsouza/go-dockerclient"
	"log"
	"net/http"
	"strings"
)

//global TTL
//global skydns url

//consul API
const REGISTER = "/v1/agent/service/register"
const DEREGISTER = "/v1/agent/service/deregister/"

type Service struct {
	Name    string
	Address string
}

//adds a service entry and a PTR entry
func AddEntry(logger *log.Logger, hostname string, ip string, TTL uint64, CONSUL string) {

	logger.Println("addEntry called")

	//delete any existing entries with this name or ip address
	DeleteEntry(logger, hostname, ip, CONSUL)

	fmt.Println("AddEntry completed")

}

//delete both the service entry and the PTR entry
func DeleteEntry(logger *log.Logger, hostname string, ip string, CONSUL string) {
	logger.Println("DeleteEntry called...")
	logger.Println("DeleteEntry completed...")

}

//return the reverse ip
func reverseIP(ip string) string {
	//"1.0.0.10.in-addr.arpa."},
	//assume ip has 4 numbers 1.2.3.4
	arr := strings.Split(ip, ".")
	return arr[3] + "." + arr[2] + "." + arr[1] + "." + arr[0] + ".in-addr.arpa"
}

// Action makes a skydns REST API call based on the docker event
func Action(logger *log.Logger, action string, containerId string, docker *dockerapi.Client, TTL uint64, CONSUL string, DOMAIN string) {

	//if we fail on inspection, that is ok because we might
	//be checking for a crufty container that no longer exists
	//due to docker being shutdown uncleanly

	container, dockerErr := docker.InspectContainer(containerId)
	if dockerErr != nil {
		logger.Printf("unable to inspect container:%s %s", containerId, dockerErr)
		return
	}
	var hostname = container.Name[1:] + "." + DOMAIN
	var ipaddress = container.NetworkSettings.IPAddress

	if ipaddress == "" {
		logger.Println("no ipaddress returned for container: " + hostname)
		return
	}

	switch action {
	case "start":
		logger.Println("new container name=" + container.Name[1:] + " ip:" + ipaddress)
		AddEntry(logger, hostname, ipaddress, TTL, CONSUL)
	case "stop":
		logger.Println("removing container name=" + container.Name[1:] + " ip:" + ipaddress)
		DeleteEntry(logger, hostname, ipaddress, CONSUL)
	case "destroy":
		logger.Println("removing container name=" + container.Name[1:] + " ip:" + ipaddress)
		DeleteEntry(logger, hostname, ipaddress, CONSUL)
	default:
	}

}

func Deregister(consulURL string, logger *log.Logger, serviceName string) error {
	var httpresponse *http.Response
	var err error

	httpresponse, err = http.Get(consulURL + DEREGISTER + "/" + serviceName)
	if err != nil {
		logger.Println(err.Error())
		return err
	}

	logger.Printf("deregister status code: %d\n", httpresponse.StatusCode)
	if httpresponse.StatusCode != 200 {
		return errors.New("deregister: invalid status code " + httpresponse.Status)
	}

	return err
}

func Register(consulURL string, logger *log.Logger, service *Service) error {
	var httpresponse *http.Response
	var err error
	var buf []byte

	buf, err = json.Marshal(service)
	if err != nil {
		log.Println(err.Error())
		return err
	}

	body := bytes.NewBuffer(buf)
	log.Println(body.String())

	httpresponse, err = http.Post(consulURL+REGISTER, "application/json", body)
	if err != nil {
		logger.Println(err.Error())
		return err
	}

	logger.Printf("register status code: %d\n", httpresponse.StatusCode)
	if httpresponse.StatusCode != 200 {
		return errors.New("register: invalid status code " + httpresponse.Status)
	}
	return err
}
