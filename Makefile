include env_make
NS = mcroth
VERSION ?= latest

REPO = docker-janus
NAME = janus
INSTANCE = jessie

.PHONY: datachannels websockets boringssl mqtt rabbitmq build push shell run start stop rm release

boringssl:
	docker build --build-arg JANUS_WITH_BORINGSSL=1 -t $(NS)/$(REPO):$(VERSION) .

mqtt:
	docker build --build-arg JANUS_WITH_MQTT=1 -t $(NS)/$(REPO):$(VERSION) .

rabbitmq:
	docker build --build-arg JANUS_WITH_RABBITMQ=1 -t $(NS)/$(REPO):$(VERSION) .

datachannels:
	docker build --build-arg JANUS_WITH_DATACHANNELS=1 -t $(NS)/$(REPO):$(VERSION) .

websockets:
	docker build --build-arg JANUS_WITH_WEBSOCKETS=1 -t $(NS)/$(REPO):$(VERSION) .

build:
	docker build -t $(NS)/$(REPO):$(VERSION) .

push:
	docker push $(NS)/$(REPO):$(VERSION)

shell:
	docker run --rm --name $(NAME)-$(INSTANCE) -i -t $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(REPO):$(VERSION) /bin/bash

run:
	docker run --rm --name $(NAME)-$(INSTANCE) $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(REPO):$(VERSION)

start:
	docker run -d --name $(NAME)-$(INSTANCE) $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(REPO):$(VERSION)

stop:
	docker stop $(NAME)-$(INSTANCE)

rm:
	docker rm $(NAME)-$(INSTANCE)

release: build
	make push -e VERSION=$(VERSION)

default: build
