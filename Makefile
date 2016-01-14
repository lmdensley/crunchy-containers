OSFLAVOR=rhel7
all:
	sudo docker build -t crunchy-container -f Dockerfile.$(OSFLAVOR) .
	sudo docker tag -f crunchy-container:latest crunchydata/crunchy-container

