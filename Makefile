MAKEFLAGS = -s

.PYONY: goyacc
goyacc:
	@if ! which goyacc > /dev/null; then \
	  go get golang.org/x/tools/cmd/goyacc; \
	fi

parser.go: goyacc parser.y
	goyacc -o parser.go parser.y
	gofmt -w parser.go

clean:
	rm -f y.output parser.go