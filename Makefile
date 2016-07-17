
build:
	docker build .

run:
	docker run -it --rm -v $PWD:/package -p 8080:8080 6e0153663fa4

