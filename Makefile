BIN:=1brc


default: all

## default: Runs tests and benchmarks
.PHONY: default
all: build test




## help: print this help message
.PHONY: help
help:
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Commands:'
	@sed -n 's/^## //p' ${MAKEFILE_LIST} | column -t -s ':' |  sed -e 's/^/ /'




## clean: clean up all artifacts
.PHONY: clean
clean:
	docker rm -f ${BIN}
	docker rmi -f ${BIN}




## build: build the binary
.PHONY: build
build:
	docker build -t ${BIN} .




## test: Test and benchmark
.PHONY: test
test:
	docker run ${BIN}
