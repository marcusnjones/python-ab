SHELL := $(shell which bash)

YOUR_HOSTNAME := $(shell hostname | cut -d "." -f1 | awk '{print $1}')

export HOST_IP=$(shell curl ipv4.icanhazip.com 2>/dev/null)

username := $(shell git config --get github.user)
container_name := $(shell basename -s .git `git config --get remote.origin.url`)

GIT_BRANCH  = $(shell git rev-parse --abbrev-ref HEAD)
GIT_SHA     = $(shell git rev-parse HEAD)
BUILD_DATE  = $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")

TAG ?= $(VERSION)
ifeq ($(TAG),@branch)
	override TAG = $(shell git symbolic-ref --short HEAD)
	@echo $(value TAG)
endif

# verify that certain variables have been defined off the bat
check_defined = \
    $(foreach 1,$1,$(__check_defined))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $(value 2), ($(strip $2)))))

list_allowed_args := name inventory

# shims
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))

.PHONY: list help build-dev build-prod up-dev force-up-dev up-prod force-up-prod run-dev run-prod force-run-dev force-run-dev

help:
	@echo "Make commands for provisioning $(container_name)"

list:
	@$(MAKE) -qp | awk -F':' '/^[a-zA-Z0-9][^$#\/\t=]*:([^=]|$$)/ {split($$1,A,/ /);for(i in A)print A[i]}' | sort

build-dev:
	docker-compose -f docker-compose.dev.yml build --no-cache

build-prod:
	docker-compose -f docker-compose.prod.yml build --no-cache

up-dev:
	docker-compose -f docker-compose.dev.yml up

force-up-dev:
	docker-compose -f docker-compose.dev.yml up --force-recreate

up-prod:
	docker-compose -f docker-compose.prod.yml up

force-up-prod:
	docker-compose -f docker-compose.prod.yml up --force-recreate

run-dev: build-dev up-dev

run-prod: build-prod up-prod

force-run-dev: build-dev force-up-dev

force-run-dev: build-dev force-up-prod
