import PackageDescription

let package = Package(
    name: "SessionMiddleware",
    dependencies: [
        .Package(url: "https://github.com/Zewo/HTTP.git", majorVersion: 0, minor: 7),
        .Package(url: "https://github.com/Zewo/UUID.git", majorVersion: 0, minor: 2)
    ]
)
