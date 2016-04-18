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
	_ "github.com/lib/pq"
	"log"
	"os"
)

var VAC_FULL bool
var VAC_HOST string
var VAC_ANALYZE bool
var VAC_ALL bool
var VAC_VERBOSE bool
var VAC_FREEZE bool
var VAC_TABLE string
var PG_USER string
var PG_PORT string
var PG_DATABASE string
var PG_PASSWORD string

const VERSION = "1.1.2"

var logger *log.Logger

func main() {
	logger = log.New(os.Stdout, "logger: ", log.Lshortfile|log.Ldate|log.Ltime)

	logger.Println("vacuum " + VERSION + ": starting")

	getEnvVars()

	process()

}

func process() {
	var err error

	var conn *sql.DB

	conn, err = sql.Open("postgres",
		"sslmode=disable user="+PG_USER+
			" host="+VAC_HOST+" port="+PG_PORT+
			" dbname="+PG_DATABASE+" password="+PG_PASSWORD)
	if err != nil {
		logger.Println("could not connect to " + VAC_HOST)
		logger.Println(err.Error())
		os.Exit(2)
	}
	defer conn.Close()
	err = someQuery(conn)
	if err != nil {
		logger.Println(err.Error())
		logger.Println("error performing query")
		os.Exit(2)
	}

}

func getEnvVars() error {
	//get the polling interval (in minutes, 3 minutes is the default)
	var err error

	PG_USER = os.Getenv("PG_USER")
	if PG_USER == "" {
		logger.Println("PG_USER not set, required env var")
		return errors.New("PG_USER env var not set")
	}
	PG_PORT = os.Getenv("PG_PORT")
	if PG_PORT == "" {
		logger.Println("PG_PORT not set, using default of 5432")
		PG_PORT = "5432"
	}
	PG_DATABASE = os.Getenv("PG_DATABASE")
	if PG_DATABASE == "" {
		logger.Println("PG_DATABASE not set, using default of postgres")
		PG_DATABASE = "postgres"
	}
	PG_PASSWORD = os.Getenv("PG_PASSWORD")
	if PG_PASSWORD == "" {
		logger.Println("PG_PASSWORD not set, required env var")
		return errors.New("PG_PASSWORD env var not set")
	}

	VAC_HOST = os.Getenv("VAC_HOST")
	if VAC_HOST == "" {
		logger.Println("VAC_HOST not set, required env var")
		return errors.New("VAC_HOST env var not set")
	}
	var temp = os.Getenv("VAC_FULL")
	if temp == "" {
		logger.Println("VAC_FULL not set, using default of true")
		VAC_FULL = true
	}
	temp = os.Getenv("VAC_ANALYZE")
	if temp == "" {
		logger.Println("VAC_ANALYZE not set, using default of true")
		VAC_ANALYZE = true
	}
	temp = os.Getenv("VAC_ALL")
	if temp == "" {
		logger.Println("VAC_ALL not set, using default of true")
		VAC_ALL = true
	}
	temp = os.Getenv("VAC_VERBOSE")
	if temp == "" {
		logger.Println("VAC_VERBOSE not set, using default of true")
		VAC_VERBOSE = true
	}
	temp = os.Getenv("VAC_FREEZE")
	if temp == "" {
		logger.Println("VAC_FREEZE not set, using default of false")
		VAC_FREEZE = false
	} else {
		if temp == "true" {
			VAC_FREEZE = true
		}
	}

	logger.Println("VAC_FULL:%t\n", VAC_FULL)
	logger.Println("VAC_HOST: %s\n", VAC_HOST)
	logger.Println("VAC_ANALYZE: %t\n", VAC_ANALYZE)
	logger.Println("VAC_ALL b: %t\n", VAC_ALL)
	logger.Println("VAC_VERBOSE b: %t\n", VAC_VERBOSE)
	logger.Println("VAC_FREEZE b: %t\n", VAC_FREEZE)
	logger.Println("VAC_TABLE s: %s\n", VAC_TABLE)
	logger.Println("PG_USER s: %s\n", PG_USER)
	logger.Println("PG_PORT s: %s\n", PG_PORT)
	logger.Println("PG_DATABASE s: %s\n", PG_DATABASE)
	logger.Println("PG_PASSWORD s: %s\n", PG_PASSWORD)

	return err

}

func someQuery(conn *sql.DB) error {
	var err error
	var rows *sql.Rows
	rows, err = conn.Query("vacuum analyze jefftable")
	if err != nil {
		return err
	}
	defer rows.Close()
	return err
}
