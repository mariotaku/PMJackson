public protocol JsonMappable {
    init()
}

public protocol JsonFieldConverter {
    associatedtype T
    
    static func parse(_ parser: JsonParser) -> T!
    
}

open class JsonMapper<T: JsonMappable> {
    
    public init() {
        
    }
    
    open func parse(_ parser: JsonParser) -> T! {
        fatalError("Not implemented")
    }
    
    open func parseField(_ instance: T, _ fieldName: String, _ parser: JsonParser) {
        // No-op
    }
    
}
