package collectapi

import (
	"fmt"
	"github.com/prometheus/client_golang/prometheus"
)

func WritePrometheusMetrics(PROM_GATEWAY string, HOST string, metrics []Metric) error {
	var err error
	fmt.Println("writing metrics")
	for i := 0; i < len(metrics); i++ {
		metrics[i].Print()

		opts := prometheus.GaugeOpts{
			Name: metrics[i].MetricName,
			Help: "no help available",
		}

		labels := make(map[string]string)

		labels["DatabaseName"] = metrics[i].DatabaseName
		labels["Units"] = metrics[i].Units
		if metrics[i].TableName != "" {
			labels["TableName"] = metrics[i].TableName
		}

		if metrics[i].LockType != "" {
			labels["LockType"] = metrics[i].LockType
			labels["LockMode"] = metrics[i].LockMode
		}

		opts.ConstLabels = labels

		newMetric := prometheus.NewGauge(opts)
		newMetric.Set(float64(metrics[i].Value))
		if err := prometheus.PushCollectors(
			"crunchy_collect", HOST,
			PROM_GATEWAY,
			newMetric,
		); err != nil {
			fmt.Println("Could not push completion time to Pushgateway:", err)
			return err
		}
	}
	return err
}
