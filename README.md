# swift-package-converter
API to convert Package.swift files into JSON

Runs on `http://192.241.154.173`.

# :rocket: Endpoints

## `POST /to-json`
- *Body*: data must be the `Package.swift` string contents.
- *Returns*: JSON response with the converted representation (uses `swift package dump-package`).

## `GET /swift-version`
- *Returns*: string version of the Swift toolchain used.

# :bolts: Installation

Since the above IP might go away at any point, without warnings, please deploy the converter on your own server if you're relying on it.

# Local
 For running locally, just

```
swift build
.build/debug/App //launches server on port 8080
```
# Server

I recommend using Docker, with which the installation steps on a server are:

- ensure you have Docker installed
- `git clone https://github.com/czechboy0/swift-package-converter.git`
- `cd swift-package-converter`
- `docker build .` (will spit out a container ID at the end, use that in the next step under CONTAINER_ID)
- `docker run -it -d --restart=on-failure -v $PWD:/package -p 80:8080 CONTAINER_ID`

This will launch and bind the server to port 80 on the server.

(If you have ideas of improving the deployment steps with Docker, please PR it, I'm new to Docker.)

:gift_heart: Contributing
------------
Please create an issue with a description of your problem or open a pull request with a fix.

:v: License
-------
MIT

:alien: Author
------
Honza Dvorsky - http://honzadvorsky.com, [@czechboy0](http://twitter.com/czechboy0)

