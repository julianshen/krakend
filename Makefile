.PHONY: all deps test build benchmark coveralls build_gin_example build_dns_example build_mux_example build_gorilla_example build_negroni_example build_httpcache_example build_jwt_example

PACKAGES = $(shell go list ./... | grep -v /examples/)

all: deps test build

deps:
	go get -u github.com/gin-gonic/gin
	go get -u github.com/gorilla/mux
	go get -u github.com/urfave/negroni

test:
	go fmt ./...
	go test -v -cover $(PACKAGES)
	go vet ./...

benchmark:
	@echo "Proxy middleware stack"
	@go test -bench=BenchmarkProxyStack -benchtime=3s ./proxy
	@echo "Proxy middlewares"
	@go test -bench="BenchmarkNewLoadBalanced|BenchmarkNewConcurrent|BenchmarkNewRequestBuilder|BenchmarkNewMergeData" -benchtime=3s ./proxy
	@echo "Response manipulation"
	@echo "Response property whitelisting"
	@go test -bench=BenchmarkEntityFormatter_whitelistingFilter -benchtime=3s ./proxy
	@echo "Response property blacklisting"
	@go test -bench=BenchmarkEntityFormatter_blacklistingFilter -benchtime=3s ./proxy
	@echo "Response property groupping"
	@go test -bench=BenchmarkEntityFormatter_grouping -benchtime=3s ./proxy
	@echo "Response property mapping"
	@go test -bench=BenchmarkEntityFormatter_mapping -benchtime=3s ./proxy
	@echo "Request generator"
	@go test -bench=BenchmarkRequestGeneratePath -benchtime=3s ./proxy

build: build_gin_example build_dns_example build_mux_example build_gorilla_example build_negroni_example build_httpcache_example build_jwt_example

build_gin_example:
	cd examples/gin/ && make && cd ../.. && cp examples/gin/krakend_gin_example* .

build_dns_example:
	cd examples/dns/ && make && cd ../.. && cp examples/dns/krakend_dns_example* .

build_mux_example:
	cd examples/mux/ && make && cd ../.. && cp examples/mux/krakend_mux_example* .

build_gorilla_example:
	cd examples/gorilla/ && make && cd ../.. && cp examples/gorilla/krakend_gorilla_example* .

build_negroni_example:
	cd examples/negroni/ && make && cd ../.. && cp examples/negroni/krakend_negroni_example* .

build_httpcache_example:
	cd examples/httpcache/ && make && cd ../.. && cp examples/httpcache/krakend_httpcache_example* .

build_jwt_example:
	cd examples/jwt/ && make && cd ../.. && cp examples/jwt/krakend_jwt_example* .

coveralls: all
	go get github.com/mattn/goveralls
	sh coverage.sh --coveralls
