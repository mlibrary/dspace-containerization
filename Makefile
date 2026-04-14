.PHONY: build up up-all down clean rebuild logs wait test help

## Default target
.DEFAULT_GOAL := help

## Build the shared source image and all compose service images.
## Run this on first setup and whenever the source branch changes.
build:
	docker build -t dspace-containerization-source \
	  --build-arg GITHUB_BRANCH=$${GITHUB_BRANCH:-umich} .
	docker compose build

## Start the core services (db, solr, backend, frontend) in the background.
up:
	docker compose up -d

## Start core + all optional services (apache, express).
up-all:
	docker compose --profile optional up -d

## Stop and remove containers (volumes are preserved).
down:
	docker compose down

## Stop and remove containers AND all named volumes (full clean – destroys data).
clean:
	docker compose down -v --rmi local
	docker rmi -f dspace-containerization-source 2>/dev/null || true

## Rebuild all images from scratch and restart core services.
rebuild: clean build up

## Show logs for all running services (Ctrl-C to exit).
logs:
	docker compose logs -f

## Wait for all core services to be healthy (backend, solr, frontend).
## Polls every 5 s; times out after MAX_WAIT seconds (default 300).
wait:
	@bash tests/wait-for-stack.sh

## Run the smoke-test suite against the running local stack.
## Starts the stack first if not already running (make up), then waits, then tests.
test: up wait
	@bash tests/smoke.sh

## Show this help message.
help:
	@echo ""
	@echo "dspace-containerization – local dev Makefile"
	@echo ""
	@echo "Usage: make <target>"
	@echo ""
	@echo "  build      Build source image + all compose service images"
	@echo "  up         Start core services (db, solr, backend, frontend)"
	@echo "  up-all     Start core + optional services (apache, express)"
	@echo "  down       Stop containers (volumes preserved)"
	@echo "  clean      Stop containers and delete volumes + images"
	@echo "  rebuild    Full clean, build, and up"
	@echo "  logs       Tail logs for all services"
	@echo "  wait       Wait for all services to be healthy"
	@echo "  test       Start stack, wait, then run smoke tests"
	@echo "  help       Show this message"
	@echo ""

