ifneq (,)
  $(error This Makefile requires GNU Make. )
endif

#SHELL := bash
.PHONY: login all build push
.DEFAULT_GOAL      := help
DOCKER_BIN         ?= docker
PROTOC_VERSION     ?= 21.12
DOCKER_IMAGE       ?= leadtech/protoc
IMAGE_VERSION      ?= 0.0.1
DOCKER_FILE        ?= Dockerfile
DOCKER_BUILD_FLAGS ?=
DOCKER_BUILD_PATH  ?= $(PWD)

ENV_FILE		   ?= .env
-include $(ENV_FILE)
export $(shell [ ! -n "$(ENV_FILE)" ] || cat $(ENV_FILE) | grep -v \
    --regexp '^('$$(env | sed 's/=.*//'g | tr '\n' '|')')\=')

GIT_COMMIT ?= $(shell cut -c-8 <<< `git rev-parse HEAD`)
BRANCH ?= $(shell git rev-parse --abbrev-ref HEAD)
GIT_REPO ?= $(shell git remote get-url origin)


help: ## Show available targets
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m PHP_VERSION<[a-z.-]+> (default: 7.2.34) \n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

login:
	$(DOCKER_BIN) login -u $(DOCKER_USER)

build:
	$(DOCKER_BIN) image build $(DOCKER_BUILD_PATH) $(DOCKER_BUILD_FLAGS) \
		-f $(DOCKER_FILE) \
		--tag=${DOCKER_IMAGE}:${PROTOC_VERSION} \
		--build-arg GIT_BRANCH=$(BRANCH) \
		--build-arg PROTOC_VERSION=$(PROTOC_VERSION) \
		--build-arg GIT_REPO=$(GIT_REPO) \
		--build-arg GIT_COMMIT=$(GIT_COMMIT)

push:
	docker push $(DOCKER_IMAGE):$(PROTOC_VERSION)
