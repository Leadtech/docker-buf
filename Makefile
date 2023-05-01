ifneq (,)
  $(error This Makefile requires GNU Make. )
endif

#SHELL := bash
.PHONY: login all build push
.DEFAULT_GOAL      := help
DOCKER_BIN         ?= docker
PROTOC_VERSION     ?= 21.12
DOCKER_IMAGE       ?= leadtech/buf
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
#UNCOMMITTED_CHANGES := $(shell git status --porcelain)

help: ## Show available targets
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m PHP_VERSION<[a-z.-]+> (default: 7.2.34) \n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

login:  ## Login to docker registry
	$(DOCKER_BIN) login -u $(DOCKER_USER)

build: ## Build docker image
	@if [ -z "$(UNCOMMITTED_CHANGES)" ]; then \
		if $(DOCKER_BIN) image build ${DOCKER_BUILD_PATH} ${DOCKER_BUILD_FLAGS} \
			-f $(DOCKER_FILE) \
			--tag=${DOCKER_IMAGE}:${GIT_COMMIT} \
			--tag=${DOCKER_IMAGE}:latest \
			--label git.branch=$(BRANCH) \
			--label git.repository=$(GIT_REPO) \
			--label git.commit=$(GIT_COMMIT); then \
			echo "\033[32mBuild finished successfully.\033[0m"; \
		else \
			echo "\033[31mAn error has occurred!\033[0m"; \
			exit 1; \
		fi \
	else \
  	  echo "There are uncommitted changes. Make sure the worktree is clean before you build the image."; \
  	  exit 1; \
	fi

push: build ## Push docker image
	docker push $(DOCKER_IMAGE):$(GIT_COMMIT)
	docker push $(DOCKER_IMAGE):latest

shell:  ## Open shell
	$(DOCKER_BIN) run --rm -it  \
		$(DOCKER_IMAGE):latest \
		/bin/bash
