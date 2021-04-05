# Run the rulegen system
.PHONY: rulegen
rulegen:
	bazel query '//example/routeguide/... - attr(tags, manual, //example/routeguide/...)' > available_tests.txt; \
	bazel run --run_under="cd $$PWD && " //tools/rulegen -- --ref=$$(git describe --abbrev=0 --tags); \
	rm available_tests.txt;


# Build docs locally
.PHONY: docs
docs:
	python3 -m sphinx -c docs -a -E -T -W --keep-going docs docs/build


# Apply buildifier
.PHONY: buildifier
buildifier:
	bazel run //tools:buildifier


# Run cargo raze on the rust dependencies
.PHONY: rust_raze
rust_raze:
	cd rust/raze; \
	rm Cargo.raze.lock || true; \
	rm -r remote; \
	cargo raze;


# Run yarn to upgrade the js dependencies
.PHONY: yarn_upgrade
yarn_upgrade:
	cd js/requirements; \
	rm yarn.lock; \
	yarn install; \


# Run bundle to upgrade the Ruby dependencies
.PHONY: ruby_bundle_upgrade
ruby_bundle_upgrade:
	cd ruby; \
	rm Gemfile.lock; \
	bundle install --path /tmp/ruby-bundle; \


# Run pip-compile to upgrade python dependencies
.PHONY: pip_compile
pip_compile:
	pip-compile python/requirements.in --output-file python/requirements.txt


# Run C# package regeneration
.PHONY: csharp_regenerate_packages
csharp_regenerate_packages:
	./csharp/nuget/regenerate_packages.sh


# Run all language specific updates
.PHONY: all_updates
all_updates: rust_raze yarn_upgrade ruby_bundle_upgrade pip_compile csharp_regenerate_packages


# A collection of targets that build routeguide clients
.PHONY: clients
clients:
	bazel build \
		//cpp/example/routeguide:client \
		//go/example/routeguide/client \
		//java/example/routeguide:client \
		//python/example/routeguide:client \
		//scala/example/routeguide:client \

# A collection of targets that build routeguide servers
.PHONY: servers
servers:
	bazel build \
		//cpp/example/routeguide:server \
		//go/example/routeguide/server \
		//java/example/routeguide:server \
		//python/example/routeguide:server \
		//scala/example/routeguide:server \


# A collection of test targets
.PHONY: tests
tests:
	bazel test \
		//cpp/example/routeguide/... \
		//java/example/routeguide/... \
		//go/example/routeguide/... \

.PHONY: pending_clients
pending_clients:
	bazel build \
		//android/example/routeguide:client \
		//js/example/routeguide:client \
		//ruby/example/routeguide:client \
		//rust/example/routeguide:client

.PHONY: pending_servers
pending_servers:
	bazel build \
		//js/example/routeguide:server \
		//ruby/example/routeguide:server \
		//rust/example/routeguide:server

.PHONY: all
all: clients servers tests


# Pull in auto-generated examples makefile
include example/Makefile.mk

# Pull in auto-generated test workspaces makefile
include test_workspaces/Makefile.mk
