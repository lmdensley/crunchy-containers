OSFLAVOR=rhel7
PGVERSION=9.5

ifndef BUILDBASE
	export BUILDBASE=$(GOPATH)/src/github.com/crunchydata/crunchy-containers
endif

gendeps:
	godep save \
	github.com/crunchydata/crunchy-containers/collectapi \
	github.com/crunchydata/crunchy-containers/dnsbridgeapi \
	github.com/crunchydata/crunchy-containers/dbaapi \
	github.com/crunchydata/crunchy-containers/dba \
	github.com/crunchydata/crunchy-containers/badger 

docbuild:
	cd docs && ./build-docs.sh
postgres:
	sudo docker build -t crunchy-postgres -f $(OSFLAVOR)/$(PGVERSION)/Dockerfile.postgres.$(OSFLAVOR) .
	sudo docker tag -f crunchy-postgres:latest crunchydata/crunchy-postgres
watch:
	cp /usr/bin/oc bin/watch
	sudo docker build -t crunchy-watch -f $(OSFLAVOR)/$(PGVERSION)/Dockerfile.watch.$(OSFLAVOR) .
	sudo docker tag -f crunchy-watch:latest crunchydata/crunchy-watch
pgpool:
	sudo docker build -t crunchy-pgpool -f $(OSFLAVOR)/$(PGVERSION)/Dockerfile.pgpool.$(OSFLAVOR) .
	sudo docker tag -f crunchy-pgpool:latest crunchydata/crunchy-pgpool
pgbadger:
	cd badger && godep go install badgerserver.go
	cp $(GOBIN)/badgerserver bin/pgbadger
	sudo docker build -t crunchy-pgbadger -f $(OSFLAVOR)/$(PGVERSION)/Dockerfile.pgbadger.$(OSFLAVOR) .
	sudo docker tag -f crunchy-pgbadger:latest crunchydata/crunchy-pgbadger
collectserver:
	cd collect && godep go install collectserver.go
	cp $(GOBIN)/collectserver bin/collect
	sudo docker build -t crunchy-collect -f $(OSFLAVOR)/$(PGVERSION)/Dockerfile.collect.$(OSFLAVOR) .
	sudo docker tag -f crunchy-collect:latest crunchydata/crunchy-collect
dbaserver:
	cd dba && godep go install dbaserver.go
	cp $(GOBIN)/dbaserver bin/dba
	sudo docker build -t crunchy-dba -f $(OSFLAVOR)/Dockerfile.dba.$(OSFLAVOR) .
	sudo docker tag -f crunchy-dba:latest crunchydata/crunchy-dba
vacuum:
	cd dba && godep go install vacuum.go
	cp $(GOBIN)/vacuum bin/vacuum
	sudo docker build -t crunchy-vacuum -f $(OSFLAVOR)/Dockerfile.vacuum.$(OSFLAVOR) .
	sudo docker tag -f crunchy-vacuum:latest crunchydata/crunchy-vacuum
dns:
	cd dnsbridge && godep go install dnsbridgeserver.go
	cd dnsbridge && godep go install consulclient.go
	cp $(GOBIN)/consul bin/dns/
	cp $(GOBIN)/dnsbridgeserver bin/dns/
	cp $(GOBIN)/consulclient bin/dns/
	sudo docker build -t crunchy-dns -f $(OSFLAVOR)/Dockerfile.dns.$(OSFLAVOR) .
	sudo docker tag -f crunchy-dns:latest crunchydata/crunchy-dns
backup:
	sudo docker build -t crunchy-backup -f $(OSFLAVOR)/$(PGVERSION)/Dockerfile.backup.$(OSFLAVOR) .
	sudo docker tag -f crunchy-backup:latest crunchydata/crunchy-backup
prometheus:
	sudo docker build -t crunchy-prometheus -f $(OSFLAVOR)/Dockerfile.prometheus.$(OSFLAVOR) .
	sudo docker tag -f crunchy-prometheus:latest crunchydata/crunchy-prometheus
download:
	wget -O prometheus-pushgateway.tar.gz https://github.com/prometheus/pushgateway/releases/download/0.2.0/pushgateway-0.2.0.linux-amd64.tar.gz
	wget -O prometheus.tar.gz https://github.com/prometheus/prometheus/releases/download/0.17.0/prometheus-0.17.0.linux-amd64.tar.gz 
	wget -O grafana.tar.gz  https://grafanarel.s3.amazonaws.com/builds/grafana-2.6.0.linux-x64.tar.gz
	wget -O /tmp/consul_0.6.4_linux_amd64.zip https://releases.hashicorp.com/consul/0.6.4/consul_0.6.4_linux_amd64.zip
	unzip /tmp/consul*.zip
	rm /tmp/consul*.zip
	mv consul $(GOBIN)
grafana:
	sudo docker build -t crunchy-grafana -f $(OSFLAVOR)/Dockerfile.grafana.$(OSFLAVOR) .
	sudo docker tag -f crunchy-grafana:latest crunchydata/crunchy-grafana

all:
	make postgres
	make backup
	make watch
	make pgpool
	make pgbadger
	make collectserver
	make dns
	make download
	make grafana
	make prometheus
	make dba
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
	./tests/openshift/test-scope.sh; /usr/bin/test "$$?" -eq 0
	./tests/openshift/test-backup.sh; /usr/bin/test "$$?" -eq 0

