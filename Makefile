mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
working_path := $(abspath $(dir mkfile_path))
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))

VERSION ?= $(shell git describe --tags --always --dirty)
ifeq (,${VERSION})
VERSION := v0.0.1
endif

BIN_PATH        := $(working_path)/bin
DOCKERFILE_PATH := $(working_path)/build
BUILD_TEMP ?= ${working_path}/.build
export BUILD_TEMP


DOCKER_REGISTRY ?= docker.io/${USER}
DOCKER_REPOSITORY ?= terraform
DOCKER_TAG ?= ${VERSION}
DOCKER_IMAGE ?= ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}:${DOCKER_TAG}


KUBECTL ?= $(shell which kubectl)
KUBE_APPLY ?= ${KUBECTL} apply -f -
KUBE_DELETE ?= ${KUBECTL} delete -f -
ifeq ($(DRYRUN), true)
KUBE_APPLY := cat
KUBE_DELETE := cat
endif

export KUBECONFIG
NAMESPACE ?= $(shell kubectl config get-contexts --no-headers | grep '*' | grep -Eo '\S+$$')


.build-prereqs::
ifeq ("","$(wildcard $${BUILD_TEMP}/bin )")
	@{ \
	mkdir -p ${BUILD_TEMP}/bin ; \
	}
endif


all: docker

docker:
	docker build \
		--build-arg VERSION="${VERSION}" \
		-f build/Dockerfile \
		. -t ${DOCKER_IMAGE}

run:
	docker run \
		--rm \
		-it \
		--user $(id -u):$(id -g) \
		--env="HOME=/home/${USER}" \
		--volume="/home/${USER}:/home/${USER}" \
		--volume="/etc/group:/etc/group:ro" \
		--volume="/etc/passwd:/etc/passwd:ro" \
		--volume="/etc/shadow:/etc/shadow:ro" \
		--volume="${working_path}:/src/terraform-kubernetes-multi-cloud" \
		${DOCKER_IMAGE}
