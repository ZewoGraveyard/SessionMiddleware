import PackageDescription

let package = Package(
    name: "SessionMiddleware",
    dependencies: [
        .Package(url: "https://github.com/Zewo/HTTP.git", majorVersion: 0, minor: 4),
        .Package(url: "https://github.com/Danappelxx/UUID.git", majorVersion: 0, minor: 1)
    ]
)
