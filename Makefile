.PHONY: help dev up-detached down clean logs build build-frontend setup install_deps_rails console bash rspec rubocop rubocop-fix test-frontend vitest svelte-check svelte-lint svelte-lint-fix svelte-format svelte-format-check lint-fix-all

.DEFAULT_GOAL := help

COMPOSE = docker compose

help:
	@echo "djoulde-transports — local dev targets"
	@echo ""
	@echo "Stack"
	@echo "  make dev                  Build images then start the full stack (mysql, redis, dev, proxy, frontend)"
	@echo "  make up-detached          Start the stack in the background"
	@echo "  make down                 Stop and remove all services"
	@echo "  make clean                Stop containers and remove orphans"
	@echo "  make logs                 Tail dev + proxy logs"
	@echo "  make build                Rebuild the Rails dev image"
	@echo "  make build-frontend       Rebuild the frontend image (Node version changes, etc.)"
	@echo "  make setup                Bring deps up, install gems, run db:prepare"
	@echo ""
	@echo "Rails"
	@echo "  make install_deps_rails   Install gem dependencies (bundle)"
	@echo "  make console              Rails console (requires running stack)"
	@echo "  make bash                 Bash shell in the dev container (requires running stack)"
	@echo "  make rspec [PATH]         Run RSpec; forwards path args"
	@echo "  make rubocop              Run rubocop"
	@echo "  make rubocop-fix          Run rubocop with auto-correct"
	@echo ""
	@echo "Frontend"
	@echo "  make test-frontend        Run all frontend tests"
	@echo "  make vitest [PATH]        Run Vitest (optional path to a single file)"
	@echo "  make svelte-check         Type-check with svelte-check"
	@echo "  make svelte-lint          ESLint"
	@echo "  make svelte-lint-fix      ESLint with auto-fix"
	@echo "  make svelte-format        Prettier (write)"
	@echo "  make svelte-format-check  Prettier (check only)"
	@echo ""
	@echo "All"
	@echo "  make lint-fix-all         Rubocop -A + Prettier + ESLint --fix"

install_deps_rails:
	$(COMPOSE) run --rm dev bash -c 'bundle check || bundle install'

setup: install_deps_rails
	$(COMPOSE) up -d mysql redis
	-$(COMPOSE) run --rm dev bundle exec rails db:prepare

dev: setup
	$(COMPOSE) build dev frontend
	$(COMPOSE) up dev frontend proxy

up-detached:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

clean:
	$(COMPOSE) down --remove-orphans

logs:
	$(COMPOSE) logs -f --tail=100 dev proxy

build:
	$(COMPOSE) build dev

build-frontend:
	$(COMPOSE) build frontend

console:
	$(COMPOSE) exec dev bundle exec rails console

bash:
	$(COMPOSE) exec dev bash

rubocop:
	$(COMPOSE) exec dev bundle exec rubocop

rubocop-fix:
	$(COMPOSE) exec dev bundle exec rubocop -A

# Argument forwarding: $(filter-out $@,$(MAKECMDGOALS)) extracts everything
# the user typed after `make rspec`. The catch-all `%:` rule below stops
# Make from trying to build those path arguments as their own targets.
rspec:
	$(COMPOSE) exec dev bundle exec rspec $(filter-out $@,$(MAKECMDGOALS))

test-frontend:
	cd frontend && npx vitest run

# Strip a leading slash so both
#   make vitest test/lib/components/common/Button.test.ts
#   make vitest /test/lib/components/common/Button.test.ts
# resolve to the same path.
vitest:
	cd frontend && npx vitest run $(patsubst /%,%,$(filter-out $@,$(MAKECMDGOALS)))

svelte-check:
	cd frontend && npm run check

svelte-lint:
	cd frontend && npm run lint

svelte-lint-fix:
	cd frontend && npm run lint:fix

svelte-format:
	cd frontend && npm run format

svelte-format-check:
	cd frontend && npm run format:check

lint-fix-all:
	$(COMPOSE) exec dev bundle exec rubocop -A
	cd frontend && npm run format && npm run lint:fix

# Catch-all: swallows path arguments to `make rspec ...` / `make vitest ...`.
# Required so GNU Make doesn't fail with "no rule to make target 'spec/foo'".
%:
	@:
