OSFLAVOR=centos7
PGVERSION=9.5

ifndef BUILDBASE
	export BUILDBASE=$(HOME)/crunchy-containers
endif

docbuild:
	cd docs && ./build-docs.sh
pg:
	sudo docker build -t crunchy-pg -f $(PGVERSION)/Dockerfile.$(OSFLAVOR) .
	sudo docker tag -f crunchy-pg:latest crunchydata/crunchy-pg
watch:
	cp /usr/bin/oc bin/watch
	sudo docker build -t crunchy-watch -f $(PGVERSION)/Dockerfile.watch.$(OSFLAVOR) .
	sudo docker tag -f crunchy-watch:latest crunchydata/crunchy-watch
pgpool:
	sudo docker build -t crunchy-pgpool -f $(PGVERSION)/Dockerfile.pgpool.$(OSFLAVOR) .
	sudo docker tag -f crunchy-pgpool:latest crunchydata/crunchy-pgpool
pgbadger:
	cd badger && godep restore && godep go install badgerserver.go
	cp $(GOBIN)/badgerserver bin
	sudo docker build -t crunchy-pgbadger -f $(PGVERSION)/Dockerfile.pgbadger.$(OSFLAVOR) .
	sudo docker tag -f crunchy-pgbadger:latest crunchydata/crunchy-pgbadger
collectserver:
	cd collect && godep restore && godep go install collectserver.go
	cp $(GOBIN)/collectserver bin
	sudo docker build -t crunchy-collect -f $(PGVERSION)/Dockerfile.collect.$(OSFLAVOR) .
	sudo docker tag -f crunchy-collect:latest crunchydata/crunchy-collect
backup:
	sudo docker build -t crunchy-backup -f $(PGVERSION)/Dockerfile.backup.$(OSFLAVOR) .
	sudo docker tag -f crunchy-backup:latest crunchydata/crunchy-backup

all:
	make pg
	make backup
	make watch
	make pgpool
	make pgbadger
default:
	all
test:
	./tests/standalone/test-master.sh; /usr/bin/test "$$?" -eq 0
	./tests/standalone/test-backup.sh; /usr/bin/test "$$?" -eq 0
	./tests/standalone/test-restore.sh; /usr/bin/test "$$?" -eq 0
	./tests/standalone/test-replica.sh; /usr/bin/test "$$?" -eq 0
	./tests/standalone/test-badger.sh; /usr/bin/test "$$?" -eq 0
	sudo docker stop master

