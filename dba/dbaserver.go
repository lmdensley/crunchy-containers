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
	"github.com/crunchydata/crunchy-containers/dbaapi"
	"github.com/robfig/cron"
	"log"
	"os"
	"time"
)

var POLL_INT = int64(3)

const VERSION = "1.1.2"

var logger *log.Logger

func main() {
	logger = log.New(os.Stdout, "logger: ", log.Lshortfile|log.Ldate|log.Ltime)

	logger.Println("dbaserver " + VERSION + ": starting")

	cron := cron.New()

	LoadSchedules(cron)

	cron.Start()

	for true {
		time.Sleep(time.Duration(POLL_INT) * time.Minute)
	}

}

func LoadSchedules(cron *cron.Cron) {
	var VAC_SCHEDULE = os.Getenv("VAC_SCHEDULE")
	var JOB_HOST = os.Getenv("JOB_HOST")

	if VAC_SCHEDULE != "" {
		logger.Println("VAC_SCHEDULE=" + VAC_SCHEDULE)

		job := dbaapi.VacJob{}
		job.Host = JOB_HOST
		job.Logger = logger
		cron.AddJob(VAC_SCHEDULE, job)
	}
}
