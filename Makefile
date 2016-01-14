OSFLAVOR=rhel7
all:
	sudo docker build -t crunchy-pg -f Dockerfile.$(OSFLAVOR) .
	sudo docker tag -f crunchy-pg:latest crunchydata/crunchy-pg

