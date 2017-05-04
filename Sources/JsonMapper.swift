public protocol JsonMappable {
    init()
}

public protocol JsonFieldConverter {
    associatedtype T
    
    static func parse(_ parser: JsonParser) -> T!
    
}

public class JsonMapper<T: JsonMappable> {
    
    public func parse(_ parser: JsonParser) -> T! {
        fatalError("Not implemented")
    }
    
    public func parseField(_ instance: T, _ fieldName: String, _ parser: JsonParser) {
        // No-op
    }
    
}
