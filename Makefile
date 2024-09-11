# -- General
SHELL := /bin/bash

# -- Podman
PODMAN               = podman
COMPOSE              = bin/compose
COMPOSE_RUN_ANSIBLE  = bin/ansible

# -- Files
PLAYBOOKS = $(shell find . ! -regex './venv/.*\|.*ci.yml\|.*compose.yml' -name '*.yml')

# ======================================================================================
# RULES

default: help

tools/ansible/.ssh/id_iagora:
	mkdir -p tools/ansible/.ssh
	cp tools/ubuntu/keys/id_iagora tools/ansible/.ssh/id_ed25519

tools/ansible/.ssh/known_hosts:
	mkdir -p tools/ansible/.ssh
	echo -n 'ubuntu ' > tools/ansible/.ssh/known_hosts
	cat tools/ubuntu/keys/ssh_host_ed25519_key.pub >> tools/ansible/.ssh/known_hosts

tools/ansible/etc/hosts:
	cp tools/ansible/etc/hosts.template tools/ansible/etc/hosts

tools/ubuntu/keys/id_iagora:
	mkdir -p tools/ubuntu/keys
	ssh-keygen -t ed25519 -f tools/ubuntu/keys/id_iagora -N ""

tools/ubuntu/keys/ssh_host_ed25519_key:
	mkdir -p tools/ubuntu/keys
	ssh-keygen -t ed25519 -f tools/ubuntu/keys/ssh_host_ed25519_key -N ""

bootstrap: ## Bootstrap the project for development
bootstrap: \
	build \
	run
.PHONY: bootstrap

build: ## Build development containers
build: \
	tools/ubuntu/keys/id_iagora \
	tools/ubuntu/keys/ssh_host_ed25519_key \
	tools/ansible/.ssh/id_iagora \
	tools/ansible/.ssh/known_hosts \
	tools/ansible/etc/hosts
	@$(PODMAN) network create --ignore iagora_bridge
	@$(COMPOSE) build
.PHONY: build

down: ## Remove development containers
	@$(COMPOSE) down --rmi all -v --remove-orphans
.PHONY: down

logs: ## Display container logs (follow mode)
	@$(COMPOSE) logs -f ubuntu
.PHONY: logs

lint: ## Run all linters
lint: \
  lint-ansible \
  lint-dockerfile \
  lint-bash
.PHONY: lint

lint-ansible: ## Lint ansible playbooks
	@echo 'lint:ansible started…'
	$(COMPOSE_RUN_ANSIBLE) ansible-lint -R $(PLAYBOOKS)
.PHONY: lint-ansible

lint-bash: ## Lint bash scripts with shellcheck
	@echo 'lint:bash started…'
	$(PODMAN) run --rm -v "${PWD}/bin:/mnt/bin" docker.io/koalaman/shellcheck:stable -x --shell=bash bin/*
.PHONY: lint-bash

lint-dockerfile: ## Lint Dockerfiles
	@echo 'lint:dockerfile started…'
	$(PODMAN) run --rm -i docker.io/hadolint/hadolint < tools/ansible/Dockerfile
	$(PODMAN) run --rm -i docker.io/hadolint/hadolint < tools/ubuntu/Dockerfile
.PHONY: lint-dockerfile

run: ## Start development containers
	@$(COMPOSE) up -d ubuntu
.PHONY: run

status: ## An alias for "podman compose ps"
	@$(COMPOSE) ps
.PHONY: status

stop: ## Stop development containers
	@$(COMPOSE) stop
.PHONY: stop

help: ## Print help for targets with comments
	@cat $(MAKEFILE_LIST) | grep -E '^[a-zA-Z_-]+:.*?## .*$$' | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.PHONY: help
