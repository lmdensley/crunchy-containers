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
	"database/sql"
	"fmt"
	_ "github.com/lib/pq"
)

func LockMetrics(HOSTNAME string, dbConn *sql.DB) []Metric {
	fmt.Println("get lock metrics")

	var metrics = make([]Metric, 0)

	dbs := GetDatabases(dbConn)
	for i := 0; i < len(dbs); i++ {
		metric := Metric{}

		var lockCount int64
		var lockType, lockMode string
		err := dbConn.QueryRow("select locktype,mode, count(*) from pg_locks, pg_database where pg_locks.database = pg_database.oid and pg_database.datname = '"+dbs[i]+"'").Scan(&lockType, &lockMode, &lockCount)
		if err != nil {
			fmt.Println("error: " + err.Error())
			return metrics
		}

		metric.Hostname = HOSTNAME
		metric.MetricName = "lock_count"
		metric.Units = "count"
		metric.Value = lockCount
		metric.LockType = lockType
		metric.LockMode = lockMode
		metric.DatabaseName = dbs[i]
		metrics = append(metrics, metric)
	}

	return metrics

}