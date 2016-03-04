OSFLAVOR=rhel7
PGVERSION=9.5
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
	go get github.com/tools/godep
	cd src/github.com/crunchydata/openshift-dedicated-container/badger && godep restore && godep go install badgerserver.go
	sudo docker build -t crunchy-pgbadger -f $(PGVERSION)/Dockerfile.pgbadger.$(OSFLAVOR) .
	sudo docker tag -f crunchy-pgbadger:latest crunchydata/crunchy-pgbadger
backup:
	sudo docker build -t crunchy-backup -f $(PGVERSION)/Dockerfile.backup.$(OSFLAVOR) .
	sudo docker tag -f crunchy-backup:latest crunchydata/crunchy-backup

all:
	make pg
	make pgpool
	make pgbadger
	make backup
default:
	all

