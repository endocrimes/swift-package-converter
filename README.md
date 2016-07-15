# swift-package-converter
API to convert Package.swift files into JSON

Runs on `https://swift-package-converter.herokuapp.com`.

# :rocket: Endpoints

## `POST /to-json`
- *Body*: data must be the `Package.swift` string contents.
- *Returns*: JSON response with the converted representation (uses `swift package dump-package`).

## `GET /swift-version`
- *Returns*: string version of the Swift toolchain used.

:gift_heart: Contributing
------------
Please create an issue with a description of your problem or open a pull request with a fix.

:v: License
-------
MIT

:alien: Author
------
Honza Dvorsky - http://honzadvorsky.com, [@czechboy0](http://twitter.com/czechboy0)

