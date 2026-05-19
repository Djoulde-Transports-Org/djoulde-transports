.PHONY: help dev up-detached down logs build setup console bash rspec rubocop vitest

.DEFAULT_GOAL := help

# Use the skeleton profile so the `frontend` placeholder is reachable until
# ticket 13 promotes it to a full service. Centralized here so flipping
# profiles (or adding more) is a one-line change.
COMPOSE = docker compose --profile skeleton

help:
	@echo "djoulde-transports — local dev targets"
	@echo ""
	@echo "  make dev            Start the full stack (mysql, redis, rails, proxy, frontend)"
	@echo "  make up-detached    Start the stack in the background"
	@echo "  make down           Stop and remove all services"
	@echo "  make logs           Tail rails + proxy logs"
	@echo "  make build          Rebuild the rails image"
	@echo "  make setup          Install bundle, install frontend deps, run db:prepare"
	@echo "  make console        Rails console (requires running stack)"
	@echo "  make bash           Bash shell in the rails container (requires running stack)"
	@echo "  make rspec [PATH]   Run RSpec; forwards path args"
	@echo "  make rubocop        Run rubocop in the rails container"
	@echo "  make vitest [PATH]  Run Vitest in the frontend container (ticket 13+)"

setup:
	$(COMPOSE) up -d mysql redis
	$(COMPOSE) run --rm rails bash -c 'bundle check || bundle install'
	# npm ci || npm install once ticket 13 lands a real frontend image
	-$(COMPOSE) run --rm rails bundle exec rails db:prepare

dev: setup
	$(COMPOSE) up rails frontend proxy

up-detached:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

logs:
	$(COMPOSE) logs -f --tail=100 rails proxy

build:
	$(COMPOSE) build rails

console:
	$(COMPOSE) exec rails bundle exec rails console

bash:
	$(COMPOSE) exec rails bash

rubocop:
	$(COMPOSE) exec rails bundle exec rubocop

# Argument forwarding: $(filter-out $@,$(MAKECMDGOALS)) extracts everything
# the user typed after `make rspec`. The catch-all `%:` rule below stops
# Make from trying to build those path arguments as their own targets.
rspec:
	$(COMPOSE) exec rails bundle exec rspec $(filter-out $@,$(MAKECMDGOALS))

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
