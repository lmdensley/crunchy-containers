OSFLAVOR=rhel7
pg:
	sudo docker build -t crunchy-ose-pg -f Dockerfile.$(OSFLAVOR) .
	sudo docker tag -f crunchy-ose-pg:latest crunchydata/crunchy-ose-pg
pgpool:
	sudo docker build -t crunchy-ose-pgpool -f Dockerfile.pgpool.$(OSFLAVOR) .
	sudo docker tag -f crunchy-ose-pgpool:latest crunchydata/crunchy-ose-pgpool
pgbadger:
	sudo docker build -t crunchy-ose-pgbadger -f Dockerfile.pgbadger.$(OSFLAVOR) .
	sudo docker tag -f crunchy-ose-pgbadger:latest crunchydata/crunchy-ose-pgbadger
backup:
	sudo docker build -t crunchy-ose-backup -f Dockerfile.backup.$(OSFLAVOR) .
	sudo docker tag -f crunchy-ose-backup:latest crunchydata/crunchy-ose-backup
all:
	make pg
	make pgpool
	make pgbadger
	make backup
default:
	all

