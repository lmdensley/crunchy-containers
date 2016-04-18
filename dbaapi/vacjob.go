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

package dbaapi

import (
	"io/ioutil"
	"log"
	"os"
)

type VacJob struct {
	Logger  *log.Logger
	Host    string
	FULL    bool
	ANALYZE bool
	ALL     bool
	VERBOSE bool
	FREEZE  bool
	TABLE   string
}

// Run this is the func that implements the cron Job interface
func (t VacJob) Run() {

	getParms(t)
	t.Logger.Println("running vac job on: " + t.Host)
	t.Logger.Println("VAC_PARMS")
	t.Logger.Printf("FULL=%t\n", t.FULL)
	t.Logger.Printf("VERBOSE=%t\n", t.VERBOSE)
	t.Logger.Printf("ALL=%t\n", t.ALL)
	t.Logger.Printf("ANALYZE=%t\n", t.ANALYZE)
	t.Logger.Printf("FREEZE=%t\n", t.FREEZE)
	t.Logger.Printf("TABLE=%s\n", t.TABLE)

	var template = getTemplate(t.Logger)
	t.Logger.Println(template)
}

func getTemplate(logger *log.Logger) string {
	var filename = "/opt/cpm/conf/vacuum-job.json"
	buff, err := ioutil.ReadFile(filename)
	if err != nil {
		logger.Println(err.Error())
		logger.Println("error reading template file, can not continue")
		os.Exit(2)
	}
	s := string(buff)
	return s
}

func getParms(t VacJob) {
	t.FULL = true
	t.ANALYZE = true
	t.ALL = true
	t.VERBOSE = false
	t.FREEZE = false
	t.TABLE = "ALL"

	var parm = os.Getenv("VAC_FULL")
	if parm != "" {
		t.FULL = true
	}

	parm = os.Getenv("VAC_ANALYZE")
	if parm != "" {
		t.ANALYZE = true
	}

	parm = os.Getenv("VAC_ALL")
	if parm != "" {
		t.ALL = true
	}
	parm = os.Getenv("VAC_VERBOSE")
	if parm != "" {
		t.VERBOSE = true
	}

	parm = os.Getenv("VAC_FREEZE")
	if parm != "" {
		t.FREEZE = true
	}

	parm = os.Getenv("VAC_TABLE")
	if parm != "" {
		t.TABLE = parm
	}

}
