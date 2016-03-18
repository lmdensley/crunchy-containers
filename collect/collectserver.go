/*
 Copyright 2016 Crunchy Data Solutions, Inc.
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
*/

package main

import (
	"database/sql"
	"errors"
	"fmt"
	"github.com/crunchydata/crunchy-containers/collectapi"
	"os"
	"strconv"
	"time"
)

var POLL_INT = int64(3)
var PG_ROOT_PASSWORD string
var PG_PORT = "5432"
var HOSTNAME string

func main() {

	fmt.Println("collectserver: starting")

	getEnvVars()

	fmt.Printf("collectserver: POLL_INT %d\n", POLL_INT)
	fmt.Printf("collectserver: HOSTNAME %s\n", HOSTNAME)
	fmt.Printf("collectserver: PG_PORT %s\n", PG_PORT)

	for true {
		//collect.Collecthc()
		time.Sleep(time.Duration(POLL_INT) * time.Minute)
		fmt.Println("sleeping..")
		process()
	}

}

func process() {
	var err error
	var metrics []collectapi.Metric

	var conn *sql.DB
	var host = HOSTNAME
	var user = "postgres"
	var port = PG_PORT
	var database = "postgres"
	var password = PG_ROOT_PASSWORD

	conn, err = collectapi.GetMonitoringConnection(host, user, port, database, password)
	if err != nil {
		fmt.Println("could not connect to " + host)
		fmt.Println(err.Error())
		return
	}
	defer conn.Close()

	metrics, err = collectapi.GetMetrics(HOSTNAME, conn)
	if err != nil {
		fmt.Println("error getting metrics from " + host)
		fmt.Println(err.Error())
		return
	}

	//write metrics to Cockpit
	err = collectapi.WriteMetrics(metrics)
	if err != nil {
		fmt.Println("error writing metrics from " + host)
		fmt.Println(err.Error())
		return
	}
}

func getEnvVars() error {
	//get the polling interval (in minutes, 3 minutes is the default)
	var err error
	var tempval = os.Getenv("POLL_INT")
	if tempval != "" {
		POLL_INT, err = strconv.ParseInt(tempval, 10, 64)
		if err != nil {
			fmt.Println(err.Error())
			fmt.Println("error in POLL_INT env var format")
			return err
		}

	}
	HOSTNAME = os.Getenv("HOSTNAME")
	if HOSTNAME == "" {
		fmt.Println("error in HOSTNAME env var, not set")
		return errors.New("HOSTNAME env var not set")
	}
	PG_ROOT_PASSWORD = os.Getenv("PG_ROOT_PASSWORD")
	if PG_ROOT_PASSWORD == "" {
		fmt.Println("error in PG_ROOT_PASSWORD env var, not set")
		return errors.New("PG_ROOT_PASSWORD env var not set")
	}
	PG_PORT = os.Getenv("PG_PORT")
	if PG_ROOT_PASSWORD == "" {
		fmt.Println("possible error in PG_PORT env var, not set, using default value")
		return nil
	}

	return err

}
