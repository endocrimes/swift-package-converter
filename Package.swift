import PackageDescription

let package = Package(
    name: "swift-package-converter",
    dependencies: [
    	.Package(url: "https://github.com/qutheory/vapor.git", majorVersion: 0, minor: 16),
    	.Package(url: "https://github.com/czechboy0/Tasks.git", majorVersion: 0, minor: 3),
    	.Package(url: "https://github.com/czechboy0/Environment.git", majorVersion: 0, minor: 5),
    ]
)
