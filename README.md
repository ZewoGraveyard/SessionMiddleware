# RedirectMiddleware
[![Zewo 0.4](https://img.shields.io/badge/Zewo-0.4-FF7565.svg?style=flat)](http://zewo.io) [![Swift 3](https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat)](https://swift.org) [![Platform Linux](https://img.shields.io/badge/Platform-Linux-lightgray.svg?style=flat)](https://swift.org) [![License MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat)](https://tldrlegal.com/license/mit-license)

Persist sessions between requests using Cookies. [Zewo](https://github.com/Zewo/Zewo) compatible.

## Usage
# Basic
A simple example looks like so:

```swift
let sessionMiddleware = SessionMiddleware()

// Using Zewo/Router module.
// With this setup, a GET request to /am-i-logged-in will return 'false',
// but, after making a GET request to /login, making another GET request to /am-i-logged-in
// will return the body 'true'.
let router = Router(middleware: sessionMiddleware) { route in

    route.get("/login") { request in
        request.session?["loggedIn"] = true
        return Response(body: "you are now logged in!")
    }

    route.get("/am-i-logged-in") { request in
        let loggedIn = request.session?["loggedIn"] as? Bool

        return Response(body: String(loggedIn ?? false))
    }
}
```

# Advanced
It is recommended to add convenience extensions to `Session` like so:

```swift
struct User {
    let name: String
}

extension Session {
    var user: User? {
        if let user = self["user"] as? User {
            return user
        }
        return nil
    }
}
```

this way, your code becomes a lot cleaner when interfacing with the session:

```swift
route.get("/login/:name") { request in
    guard let name = request.pathParameters["name"] else {
        return Response(status: .internalServerError)
    }

    request.session?["user"] = User(name: name)
    return Response(status: .created)
}

route.get("/what-is-my-name") { request in
    guard let user = request.user else {
        return Response(status: .badRequest, body: "You're not logged in yet, silly!")
    }

    return Response(body: "Your name is \(user.name)")
}
```

## Persistence
Sessions are currently stored in a simple in-memory storage, meaning that restarting the app = lose all sessions. However, the protocol for a session storage is very simple:

```swift
public protocol SessionStorage: class {
    subscript(key: Cookie.Hash) -> Session? {get set}
}
```

so you can persist your sessions easily (through a database or locally) if you'd like. To use the storage you simply initiate the middleware with it like so:

```swift
SessionMiddleware(storage: PostgreSQLSessionStorage())
```

## Installation
Simply add `SessionMiddleware` to your `Package.swift`

```swift
import PackageDescription

let package = Package(
    dependencies: [
        .Package(url: "https://github.com/Danappelxx/SessionMiddleware.git", majorVersion: 0, minor: 1),
    ]
)
```

Linux? One more step:

```shell
sudo apt-get install uuid-dev
```

## Reach out
Have any questions? I'm active on the [SwiftX](http://swiftx-slackin.herokuapp.com) and [Zewo](http://slack.zewo.io) slacks.

## License
**SessionMiddleware** is released under the MIT license. See LICENSE for details.
