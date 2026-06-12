.PHONY: help dev up-detached down clean logs build setup install_deps_rails console bash rspec rubocop vitest

.DEFAULT_GOAL := help

# Use the skeleton profile so the `frontend` placeholder is reachable until
# ticket 13 promotes it to a full service. Centralized here so flipping
# profiles (or adding more) is a one-line change.
COMPOSE = docker compose --profile skeleton

help:
	@echo "djoulde-transports — local dev targets"
	@echo ""
	@echo "  make dev            Start the full stack (mysql, redis, dev, proxy, frontend)"
	@echo "  make up-detached    Start the stack in the background"
	@echo "  make down           Stop and remove all services"
	@echo "  make clean          Stop containers and remove orphans"
	@echo "  make logs           Tail dev + proxy logs"
	@echo "  make build          Rebuild the dev image"
	@echo "  make setup          Bring deps up, install gems, run db:prepare"
	@echo "  make install_deps_rails  Install Rails application dependencies (bundle)"
	@echo "  make console        Rails console (requires running stack)"
	@echo "  make bash           Bash shell in the dev container (requires running stack)"
	@echo "  make rspec [PATH]   Run RSpec; forwards path args"
	@echo "  make rubocop        Run rubocop in the dev container"
	@echo "  make vitest [PATH]  Run Vitest in the frontend container (ticket 13+)"

install_deps_rails:
	$(COMPOSE) run --rm dev bash -c 'bundle check || bundle install'

setup: install_deps_rails
	$(COMPOSE) up -d mysql redis
	# npm ci || npm install once ticket 13 lands a real frontend image
	-$(COMPOSE) run --rm dev bundle exec rails db:prepare

dev: setup
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

# Same pattern, but strip a leading slash so both
#   make vitest spec/frontend/foo.test.ts
#   make vitest /spec/frontend/foo.test.ts
# resolve to the same in-container path.
vitest:
	$(COMPOSE) exec frontend npx vitest run $(patsubst /%,%,$(filter-out $@,$(MAKECMDGOALS)))

# Catch-all: swallows path arguments to `make rspec ...` / `make vitest ...`.
# Required so GNU Make doesn't fail with "no rule to make target 'spec/foo'".
%:
	@:
