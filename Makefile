OSFLAVOR=centos7
PGVERSION=9.5

ifndef BUILDBASE
	export BUILDBASE=$(GOPATH)/src/github.com/crunchydata/crunchy-containers
endif

gendeps:
	godep save \
	github.com/crunchydata/crunchy-containers/collectapi \
	github.com/crunchydata/crunchy-containers/dnsbridgeapi \
	github.com/crunchydata/crunchy-containers/badger 

docbuild:
	cd docs && ./build-docs.sh
pg:
	sudo docker build -t crunchy-postgres -f $(PGVERSION)/Dockerfile.$(OSFLAVOR) .
	sudo docker tag -f crunchy-postgres:latest crunchydata/crunchy-postgres
watch:
	cp /usr/bin/oc bin/watch
	sudo docker build -t crunchy-watch -f $(PGVERSION)/Dockerfile.watch.$(OSFLAVOR) .
	sudo docker tag -f crunchy-watch:latest crunchydata/crunchy-watch
pgpool:
	sudo docker build -t crunchy-pgpool -f $(PGVERSION)/Dockerfile.pgpool.$(OSFLAVOR) .
	sudo docker tag -f crunchy-pgpool:latest crunchydata/crunchy-pgpool
pgbadger:
	cd badger && godep go install badgerserver.go
	cp $(GOBIN)/badgerserver bin/pgbadger
	sudo docker build -t crunchy-pgbadger -f $(PGVERSION)/Dockerfile.pgbadger.$(OSFLAVOR) .
	sudo docker tag -f crunchy-pgbadger:latest crunchydata/crunchy-pgbadger
collectserver:
	cd collect && godep go install collectserver.go
	cp $(GOBIN)/collectserver bin/collect
	sudo docker build -t crunchy-collect -f $(PGVERSION)/Dockerfile.collect.$(OSFLAVOR) .
	sudo docker tag -f crunchy-collect:latest crunchydata/crunchy-collect
dns:
	cd dnsbridge && godep go install dnsbridgeserver.go
	cd dnsbridge && godep go install consulclient.go
	cp $(GOBIN)/consul bin/dns/
	cp $(GOBIN)/dnsbridgeserver bin/dns/
	cp $(GOBIN)/consulclient bin/dns/
	sudo docker build -t crunchy-dns -f $(PGVERSION)/Dockerfile.dns.$(OSFLAVOR) .
	sudo docker tag -f crunchy-dns:latest crunchydata/crunchy-dns
backup:
	sudo docker build -t crunchy-backup -f $(PGVERSION)/Dockerfile.backup.$(OSFLAVOR) .
	sudo docker tag -f crunchy-backup:latest crunchydata/crunchy-backup
downloadprometheus:
	wget -O prometheus-pushgateway.tar.gz https://github.com/prometheus/pushgateway/releases/download/0.2.0/pushgateway-0.2.0.linux-amd64.tar.gz
	wget -O prometheus.tar.gz https://github.com/prometheus/prometheus/releases/download/0.17.0/prometheus-0.17.0.linux-amd64.tar.gz 
prometheus:
	sudo docker build -t crunchy-prometheus -f $(PGVERSION)/Dockerfile.prometheus.$(OSFLAVOR) .
	sudo docker tag -f crunchy-prometheus:latest crunchydata/crunchy-prometheus
downloadgrafana:
	wget -O grafana.tar.gz  https://grafanarel.s3.amazonaws.com/builds/grafana-2.6.0.linux-x64.tar.gz
grafana:
	sudo docker build -t crunchy-grafana -f $(PGVERSION)/Dockerfile.grafana.$(OSFLAVOR) .
	sudo docker tag -f crunchy-grafana:latest crunchydata/crunchy-grafana
downloadconsul:
	wget -O /tmp/consul_0.6.4_linux_amd64.zip https://releases.hashicorp.com/consul/0.6.4/consul_0.6.4_linux_amd64.zip
	unzip /tmp/consul*.zip
	rm /tmp/consul*.zip
	mv consul $(GOBIN)

all:
	make pg
	make backup
	make watch
	make pgpool
	make pgbadger
	make collectserver
	make docbuild
default:
	all
test:
	./tests/standalone/test-master.sh; /usr/bin/test "$$?" -eq 0
	./tests/standalone/test-replica.sh; /usr/bin/test "$$?" -eq 0
	./tests/standalone/test-backup.sh; /usr/bin/test "$$?" -eq 0
	./tests/standalone/test-restore.sh; /usr/bin/test "$$?" -eq 0
	./tests/standalone/test-badger.sh; /usr/bin/test "$$?" -eq 0
	sudo docker stop master
testopenshift:
	./tests/openshift/test-master.sh; /usr/bin/test "$$?" -eq 0

