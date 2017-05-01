import PMJSON

public class PMJacksonParser {
    
    
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
                    currentName = event.asString()
                }
                nextIsName = !nextIsName
            } else {
                currentName = nil
                currentIsName = false
                nextIsName = false
            }
        }
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
    @discardableResult public func skipChildren() -> PMJacksonParser {
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

public extension JSONEvent {

   public func asString(_ def: String? = nil) -> String! {
        switch self {
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
            fatalError("Unexpected event \(eventType)")
        }
    }

    public func asInt64(_ def: Int64? = nil) -> Int64! {
        switch self {
        case .stringValue(let v):
            return Int64(v) ?? def
        case .int64Value(let v):
            return v
        case .doubleValue(let v):
            return Int64(v)
        case .nullValue:
            return nil
        case .error(let err):
            fatalError(err.description)
        default:
            fatalError("Unexpected event \(eventType)")
        }
    }
    
    public func asDouble64(_ def: Double? = nil) -> Double! {
        switch self {
        case .stringValue(let v):
            return Double(v) ?? def
        case .int64Value(let v):
            return Double(v)
        case .doubleValue(let v):
            return v
        case .nullValue:
            return nil
        case .error(let err):
            fatalError(err.description)
        default:
            fatalError("Unexpected event \(eventType)")
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
