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
	"fmt"
	"github.com/crunchydata/crunchy-containers/collectapi"
	"os"
	"strconv"
	"time"
)

func main() {

	fmt.Println("collectserver: starting")

	//get the polling interval (in minutes, 3 minutes is the default)
	var err error
	var POLL_INT = int64(3)
	var tempval = os.Getenv("POLL_INT")
	if tempval != "" {
		POLL_INT, err = strconv.ParseInt(tempval, 10, 64)
		if err != nil {
			fmt.Println(err.Error())
			fmt.Println("error in POLL_INT env var format")
			return
		}

	}
	fmt.Printf("collectserver: POLL_INT %d\n", POLL_INT)

	for true {
		//collect.Collecthc()
		time.Sleep(time.Duration(POLL_INT) * time.Minute)
		fmt.Println("sleeping..")
		collectapi.GetDatabases()
	}

}
