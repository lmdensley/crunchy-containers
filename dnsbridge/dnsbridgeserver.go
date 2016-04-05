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
	"errors"
	"github.com/crunchydata/crunchy-containers/dnsbridgeapi"
	"log"
	"os"
	"time"
)

const VERSION = "1.1.0"

var logger *log.Logger
var CONSUL string

func main() {
	logger = log.New(os.Stdout, "logger: ", log.Lshortfile|log.Ldate|log.Ltime)

	logger.Println("dnsbridgeserver " + VERSION + ": starting")

	getEnvVars()

	logger.Printf("dnsbridgeserver: CONSUL %s\n", CONSUL)

	for true {
		time.Sleep(time.Duration(1) * time.Minute)
		dnsbridgeapi.Something(logger)
		logger.Println("sleeping...")
	}

}

func getEnvVars() error {
	var err error
	var CONSUL = os.Getenv("CONSUL")
	if CONSUL == "" {
		logger.Println("error in CONSUL env var, not set")
		return errors.New("CONSUL env var not set")
	}
	return err

}
