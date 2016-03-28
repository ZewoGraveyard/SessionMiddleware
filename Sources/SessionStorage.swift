@_exported import HTTP

public protocol SessionStorage: class {
    subscript(key: Cookie.Hash) -> Session? {get set}
}

public final class SessionInMemoryStorage: SessionStorage {
    private var sessions: [Cookie.Hash:Session] = [:]

    public subscript(key: Cookie.Hash) -> Session? {
        get {
            return sessions[key]
        }
        set {
            sessions[key] = newValue
        }
    }
}
