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

package collectapi

import (
	"bytes"
	"database/sql"
	"fmt"
	_ "github.com/lib/pq"
	"os/exec"
	"strconv"
)

func XlogCountMetrics(HOSTNAME string, dbConn *sql.DB) []Metric {
	fmt.Println("get pg_xlog count metrics")

	var metrics = make([]Metric, 0)

	var count int

	var cmd *exec.Cmd
	cmd = exec.Command("/opt/cpm/bin/xlog-count.sh")
	var out bytes.Buffer
	var stderr bytes.Buffer
	cmd.Stdout = &out
	cmd.Stderr = &stderr
	err := cmd.Run()
	if err != nil {
		fmt.Println("error:" + err.Error())
		return metrics
	}
	fmt.Println("xlog count got back " + out.String())
	count, err = strconv.Atoi(out.String())

	metric := Metric{}
	metric.Hostname = HOSTNAME
	metric.MetricName = "xlog_count"
	metric.Units = "count"
	metric.Value = int64(count)
	metric.DatabaseName = "cluster"
	metrics = append(metrics, metric)

	return metrics

}
