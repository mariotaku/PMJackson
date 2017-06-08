import PMJSON

public class JsonParser {
    
    public private(set) var currentEvent: JSONEvent?
    
    /**
     * Get the name associated with the current token:
     * for field names it will be the same as what `currentEvent.asString()` returns;
     * for field values it will be preceding field name;
     * and for others (array values, root-level values) null.
     */
    public private(set) var currentName: String? = nil
    
    private var iter: JSONParserIterator<AnyIterator<UnicodeScalar>>
    
    private var isObject: Bool = false
    private var isArray: Bool = false
    private var nextIsName: Bool = false
    private var currentIsName: Bool = false
    
    public init(_ parser: JSONParser<AnySequence<UnicodeScalar>>) {
        self.iter = parser.makeIterator()
    }
    
    /**
     * Main iteration method, which will advance stream enough
     * to determine type of the next token, if any. If none
     * remaining (stream has no content other than possible
     * white space before ending), null will be returned.
     *
     * - returns: Next token from the stream, if any found, or null
     *   to indicate end-of-input
     */
    @discardableResult public func nextEvent() -> JSONEvent? {
        guard let event = iter.next() else {
            currentEvent = nil
            return nil
        }
        switch event {
        case .objectStart:
            isObject = true
            nextIsName = true
            currentIsName = false
            currentName = nil
        case .arrayStart:
            isArray = true
            nextIsName = false
            currentIsName = false
            currentName = nil
        case .objectEnd, .arrayEnd:
            isArray = false
            nextIsName = false
            currentIsName = false
            currentName = nil
        default:
            if (isObject) {
                currentIsName = nextIsName
                if (currentIsName) {
                    switch event {
                    case .stringValue(let name):
                        currentName = name
                    default: fatalError()
                    }
                }
                nextIsName = !nextIsName
            } else {
                currentName = nil
                currentIsName = false
                nextIsName = false
            }
        }
        currentEvent = event
        return currentEvent
    }
    
    /**
     * Method that will skip all child tokens of an array or
     * object token that the parser currently points to,
     * if stream points to
     * `objectStart` or `arrayStart`.
     * If not, it will do nothing.
     * After skipping, stream will point to **matching**
     * `objectEnd` or `arrayEnd`
     * (possibly skipping nested pairs of OBJECT/ARRAY START/END tokens
     * as well as value tokens).
     * The idea is that after calling this method, application
     * will call `nextEvent` to point to the next
     * available token, if any.
     */
    @discardableResult public func skipChildren() -> JsonParser {
        var depth = 0
        if (currentEvent != .objectStart && currentEvent != .arrayStart) {
            return self
        }
        repeat {
            guard let event = nextEvent() else {
                break
            }
            switch event {
            case .objectStart, .arrayStart:
                depth += 1
            case .objectEnd, .arrayEnd:
                depth -= 1
            default: break
            }
        } while (depth > 0)
        return self
    }
}

public extension JsonParser {
    
    public func getText() -> String {
        let event = self.currentEvent!
        switch event {
        case .stringValue(let v):
            return v
        case .error(let err):
            fatalError(err.description)
        default:
            fatalError("Unexpected event \(event.eventType)")
        }
    }
    
    public func getValueAsString(_ def: String? = nil) -> String! {
        guard let event = self.currentEvent else {
            return def
        }
        switch event {
        case .stringValue(let v):
            return v
        case .booleanValue(let v):
            return v ? "true" : "false"
        case .int64Value(let v):
            return v.description
        case .doubleValue(let v):
            return v.description
        case .nullValue:
            return nil
        case .error(let err):
            fatalError(err.description)
        default:
            fatalError("Unexpected event \(event.eventType)")
        }
    }
    
    public func getValueAsBool(_ def: Bool = false) -> Bool {
        guard let event = self.currentEvent else {
            return def
        }
        switch event {
        case .stringValue(let v):
            return Bool(v) ?? def
        case .booleanValue(let v):
            return v
        case .int64Value(let v):
            return v != 0
        case .doubleValue(let v):
            return v != 0
        case .nullValue:
            return def
        case .error(let err):
            fatalError(err.description)
        default:
            fatalError("Unexpected event \(event.eventType)")
        }
    }
    
    public func getValueAsInt(_ def: Int = 0) -> Int {
        guard let event = self.currentEvent else {
            return def
        }
        switch event {
        case .stringValue(let v):
            return Int(v) ?? def
        case .booleanValue(let v):
            return v ? 1 : 0
        case .int64Value(let v):
            return Int(v)
        case .doubleValue(let v):
            return Int(v)
        case .nullValue:
            return def
        case .error(let err):
            fatalError(err.description)
        default:
            fatalError("Unexpected event \(event.eventType)")
        }
    }
    
    public func getValueAsInt32(_ def: Int32 = 0) -> Int32 {
        guard let event = self.currentEvent else {
            return def
        }
        switch event {
        case .stringValue(let v):
            return Int32(v) ?? def
        case .booleanValue(let v):
            return v ? 1 : 0
        case .int64Value(let v):
            return Int32(v)
        case .doubleValue(let v):
            return Int32(v)
        case .nullValue:
            return def
        case .error(let err):
            fatalError(err.description)
        default:
            fatalError("Unexpected event \(event.eventType)")
        }
    }
    
    public func getValueAsInt64(_ def: Int64 = 0) -> Int64 {
        guard let event = self.currentEvent else {
            return def
        }
        switch event {
        case .stringValue(let v):
            return Int64(v) ?? def
        case .booleanValue(let v):
            return v ? 1 : 0
        case .int64Value(let v):
            return v
        case .doubleValue(let v):
            return Int64(v)
        case .nullValue:
            return def
        case .error(let err):
            fatalError(err.description)
        default:
            fatalError("Unexpected event \(event.eventType)")
        }
    }
    
    public func getValueAsDouble(_ def: Double = 0.0) -> Double {
        guard let event = self.currentEvent else {
            return def
        }
        switch event {
        case .stringValue(let v):
            return Double(v) ?? def
        case .booleanValue(let v):
            return v ? 1 : 0
        case .int64Value(let v):
            return Double(v)
        case .doubleValue(let v):
            return v
        case .nullValue:
            return def
        case .error(let err):
            fatalError(err.description)
        default:
            fatalError("Unexpected event \(event.eventType)")
        }
    }
    
}

extension JSONEvent {
    var eventType: String {
        switch self {
        case .arrayEnd: return "arrayEnd"
        case .arrayStart: return "arrayStart"
        case .booleanValue: return "boolean"
        case .decimalValue: return "decimal"
        case .doubleValue: return "double"
        case .int64Value: return "int64"
        case .error: return "error"
        case .nullValue: return "null"
        case .objectEnd: return "objectEnd"
        case .objectStart: return "objectStart"
        case .stringValue: return "string"
        }
    }
}
