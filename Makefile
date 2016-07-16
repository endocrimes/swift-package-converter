
build:
	sudo vapor docker build

run:
	sudo docker run --rm -it -v $(pwd):/vapor -p 8081:8080 qutheory/swift:DEVELOPMENT-SNAPSHOT-2016-06-06-a