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

func ObjectSizeMetrics(HOSTNAME string, dbConn *sql.DB) []Metric {
	fmt.Println("get object size metrics")

	var metrics = make([]Metric, 0)

	dbs := GetDatabases(dbConn)
	for i := 0; i < len(dbs); i++ {
		metric := Metric{}

		var dbSize int64
		err := dbConn.QueryRow("select pg_database_size(d.datname)/1024/1024 from pg_database d where d.datname = '" + dbs[i] + "'").Scan(&dbSize)
		if err != nil {
			fmt.Println("error: " + err.Error())
			return metrics
		}

		metric.Hostname = HOSTNAME
		metric.MetricName = "database_size"
		metric.Units = "megabytes"
		metric.Value = dbSize
		metric.DatabaseName = dbs[i]
		metrics = append(metrics, metric)
	}

	return metrics

}

//get the top 10 objects by size in a database
func TableSizesMetrics(HOSTNAME string, USER string, PORT string, PASSWORD string, dbConn *sql.DB) []Metric {
	var metrics = make([]Metric, 0)
	dbs := GetDatabases(dbConn)
	for i := 0; i < len(dbs); i++ {

		d, err := GetMonitoringConnection(HOSTNAME, USER, PORT, dbs[i], PASSWORD)
		if err != nil {
			fmt.Println(err.Error())
			fmt.Println("error getting db connection to " + dbs[i])
			return metrics
		}
		defer d.Close()

		var tableName string
		var tableSize, indexSize, totalSize int64
		err = d.QueryRow("SELECT table_name, "+
			"(table_size/1024/1024) AS table_size, "+
			"(indexes_size/1024/1024) AS indexes_size, "+
			"(total_size/1024/1024) AS total_size "+
			"FROM ("+
			" SELECT "+
			" table_name, "+
			" pg_table_size(table_name) AS table_size, "+
			" pg_indexes_size(table_name) AS indexes_size, "+
			" pg_total_relation_size(table_name) AS total_size "+
			" FROM ( "+
			" SELECT table_name "+
			" FROM information_schema.tables "+
			" WHERE table_schema NOT IN ('information_schema','pg_catalog') "+
			" ) AS all_tables ORDER BY total_size  DESC limit 10 "+
			" ) AS pretty_sizes").Scan(&tableName, &tableSize, &indexSize, &totalSize)
		if err != nil {
			fmt.Println("error: " + err.Error())
			return metrics
		}

		metric := Metric{}
		metric.Hostname = HOSTNAME
		metric.MetricName = "table_size"
		metric.Units = "megabytes"
		metric.Value = tableSize
		metric.DatabaseName = dbs[i]
		metric.TableName = tableName
		metrics = append(metrics, metric)

		metric2 := Metric{}
		metric2.Hostname = HOSTNAME
		metric2.MetricName = "index_size"
		metric2.Units = "megabytes"
		metric2.Value = indexSize
		metric2.DatabaseName = dbs[i]
		metric2.TableName = tableName
		metrics = append(metrics, metric2)

		metric3 := Metric{}
		metric3.Hostname = HOSTNAME
		metric3.MetricName = "total_size"
		metric3.Units = "megabytes"
		metric3.Value = totalSize
		metric3.DatabaseName = dbs[i]
		metric3.TableName = tableName
		metrics = append(metrics, metric3)
	}

	return metrics
}