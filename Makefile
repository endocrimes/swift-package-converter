
build:
	vapor docker build

run:
	docker run --rm -it -v $(PWD):/vapor -p 8081:8080 qutheory/swift:DEVELOPMENT-SNAPSHOT-2016-06-06-a