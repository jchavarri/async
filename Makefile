.DEFAULT_GOAL := build

project_name = async_app

opam_file = $(project_name).opam

db_uri = "postgresql://admin:secret@localhost:6543/async_app"

.PHONY: build
build:
	# Build the app
	dune build @all

.PHONY: install
install:
	# Install the new dependencies
	opam install --deps-only --with-doc --with-test .

.PHONY: dev
dev:
	# Create a local opam switch and install deps
	opam switch create . 4.10.0 --deps-only
	opam install -y ocaml-lsp-server dune
	opam install --locked --deps-only --with-test --with-doc -y .

.PHONY: fmt
fmt:
	# Format
	dune build @fmt --auto-promote

.PHONY: test
test:
	# Run unit tests
	dune test --force

.PHONY: run
run:
	# Build and run the app
	DATABASE_URL=$(db_uri) dune exec $(project_name)

.PHONY: run-debug
run-debug:
	# Build and run the app with Opium's internal debug messages visible
	DATABASE_URL=$(db_uri) dune exec $(project_name) -- --debug

.PHONY: migrate
migrate:
	# Run the database migrations defined in migrate/migrate.ml
	DATABASE_URL=$(db_uri) dune exec migrate

.PHONY: rollback
rollback:
	# Run the database rollback defined in migrate/rollback.ml
	DATABASE_URL=$(db_uri) dune exec rollback

.PHONY: lock
lock:
	# Generate the lock files
	opam lock -y .