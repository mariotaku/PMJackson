import PMJSON

class JacksonAlikeParser {

    var iter: JSONParserIterator<AnyIterator<UnicodeScalar>>

    private(set) var currentEvent: JSONEvent?

    var currentName: String? {
        if (!currentIsName) {
            return nil
        }
        return currentEvent?.asString()
    }

    private var isObject: Bool = false
    private var isArray: Bool = false
    private var nextIsName: Bool = false
    private var currentIsName: Bool = false

    init(_ parser: JSONParser<AnySequence<UnicodeScalar>>) {
        self.iter = parser.makeIterator()
    }

    @discardableResult func nextEvent() -> JSONEvent? {
        guard let event = iter.next() else {
            currentEvent = nil
            return nil
        }
        switch event {
        case .objectStart:
            isObject = true
            nextIsName = true
            currentIsName = false
        case .objectEnd:
            isObject = false
            nextIsName = false
            currentIsName = false
        case .arrayStart:
            isArray = true
            nextIsName = false
            currentIsName = false
        case .arrayEnd:
            isArray = false
            nextIsName = false
            currentIsName = false
        default: if (isObject) {
            currentIsName = nextIsName
            nextIsName = !nextIsName
            }
        }
        return currentEvent
    }

    func skipChildren() {
        var depth = 0
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
    }
}

extension JSONEvent {

    func asString(def: String? = nil) -> String! {
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

    func asInt64(def: Int64? = nil) -> Int64! {
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
