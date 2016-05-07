import XCTest
@testable import SessionMiddleware

class SessionMiddlewareTests: XCTestCase {

    let middleware = SessionMiddleware()

    func testCookieIsAdded() throws {
        let request = Request()

        let response = try middleware.respond(to: request, chainingTo: BasicResponder { request in
            XCTAssertNotNil(request.session)
            return Response()
        })

        XCTAssertNotNil(response.headers["set-cookie"])
    }

    func testSessionPersists() throws {
        let request1 = Request()
        var request2: Request!

        let response1 = try middleware.respond(to: request1, chainingTo: BasicResponder { req in
            request2 = req
            return Response()
        })

        let session1: Session! = request2.session
        XCTAssertNotNil(session1)
        XCTAssertNotNil(response1.headers["set-cookie"])

        let sessionToken = session1.token
        session1["key"] = "value"

        // make another request, this time with the cookie
        var request3: Request!
        let _ = try middleware.respond(to: request2, chainingTo: BasicResponder { req in
            request3 = req
            return Response()
        })

        // make sure session is still there
        let session: Session! = request3.session
        XCTAssertNotNil(session)

        // make sure its the same session
        XCTAssert(session.token == sessionToken)

        // make sure that the session persists information
        let value: Any! = session["key"]
        XCTAssertNotNil(value)
        XCTAssertNotNil(value as? String)
        XCTAssert(value as! String == "value")
    }
}

extension SessionMiddlewareTests {
    static var allTests : [(String, SessionMiddlewareTests -> () throws -> Void)] {
        return [
           ("testCookieIsAdded", testCookieIsAdded),
           ("testSessionPersists", testSessionPersists)
        ]
    }
}
