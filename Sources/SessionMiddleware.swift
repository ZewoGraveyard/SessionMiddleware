@_exported import HTTP
@_exported import UUID

public final class SessionMiddleware: Middleware {

    public static let cookieName = "zewo-session"

    public let storage: SessionStorage

    public init(storage: SessionStorage = SessionInMemoryStorage()) {
        self.storage = storage
    }

    public func respond(request: Request, chain: Responder) throws -> Response {

        var request = request

        let (cookie, createdCookie): (Cookie, Bool) = {

            // if request contains a session cookie, return that cookie
            if let requestCookie = request.cookies.filter({ $0.name == SessionMiddleware.cookieName }).first {
                return (requestCookie, false)
            }

            // otherwise, create a new cookie and insert it into the request
            let cookie = Cookie(name: SessionMiddleware.cookieName, value: UUID().description)
            request.cookies.insert(cookie)
            return (cookie, true)
        }()

        // ensure that we have a session, and attach it to the request
        let session = storage[cookie.extendedHash] ?? createNewSession(cookie)
        request.storage[SessionMiddleware.cookieName] = session

        // at this point, we have a cookie and a session. call the rest of the chain!
        var response = try chain.respond(request)

        // if no cookie was originally in the request, we should put it in the response
        if createdCookie {
            let cookie = AttributedCookie(name: cookie.name, value: cookie.value)
            response.cookies.insert(cookie)
        }

        // done! request & response have the session cookie, and request had the session
        return response
    }

    private func createNewSession(cookie: Cookie) -> Session {
        // where cookie.value is the cookie uuid
        let session = Session(token: cookie.value)
        storage[cookie.extendedHash] = session
        return session
    }
}

extension Request {
    public var session: Session? {
        return storage[SessionMiddleware.cookieName].flatMap { $0 as? Session }
    }
}

extension Cookie {
    public typealias Hash = Int
    public var extendedHash: Hash {
        return "\(name)+\(value)".hashValue
    }
}
