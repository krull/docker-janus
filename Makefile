include env_make
NS = jemmic
VERSION ?= latest

REPO = docker-janus
NAME = janus
INSTANCE = buster

.PHONY: build push shell run start stop rm release

build:
	docker build --no-cache -t $(NS)/$(REPO):$(VERSION) .

push:
	docker push $(NS)/$(REPO):$(VERSION)

shell:
	docker exec -it $(NAME)-$(INSTANCE) /bin/bash

run:
	docker run --rm --name $(NAME)-$(INSTANCE) $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(REPO):$(VERSION)

start:
	docker start $(NAME)-$(INSTANCE)

stop:
	docker stop $(NAME)-$(INSTANCE)

rm:
	docker rm $(NAME)-$(INSTANCE)

release: build
	make push -e VERSION=$(VERSION)

default: build
