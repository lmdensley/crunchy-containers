OSFLAVOR=centos7
pg:
	sudo docker build -t crunchy-pg -f Dockerfile.$(OSFLAVOR) .
	sudo docker tag -f crunchy-pg:latest crunchydata/crunchy-pg
pgpool:
	sudo docker build -t crunchy-pgpool -f Dockerfile.pgpool.$(OSFLAVOR) .
	sudo docker tag -f crunchy-pgpool:latest crunchydata/crunchy-pgpool
backup:
	sudo docker build -t crunchy-backup -f Dockerfile.backup.$(OSFLAVOR) .
	sudo docker tag -f crunchy-backup:latest crunchydata/crunchy-backup
all:
	make pg
	make pgpool
default:
	all

