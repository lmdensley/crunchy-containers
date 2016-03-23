package collectapi

import (
	"fmt"
	"github.com/prometheus/client_golang/prometheus"
	"os"
	"time"
)

func WritePrometheusMetrics(metrics []Metric) error {
	var err error
	fmt.Println("writing metrics")
	for i := 0; i < len(metrics); i++ {
		metrics[i].Print()
	}

	hostname, _ := os.Hostname()
	completionTime := prometheus.NewGauge(prometheus.GaugeOpts{
		Name: "crunchy_test",
		Help: "a test metric",
	})
	completionTime.Set(float64(time.Now().Unix()))
	if err := prometheus.PushCollectors(
		"crunchy_test", hostname,
		"http://crunchy-scope:9091",
		completionTime,
	); err != nil {
		fmt.Println("Could not push completion time to Pushgateway:", err)
		return err
	}
	fmt.Println("wrote to prometheus pushgateway")
	return err
}
