import Foundation

public protocol Bridged: AnyObject {
    associatedtype Bridging
    var backing: Bridging { get }
    init(_ backing: Bridging)
}

public protocol Bridgeable: _ObjectiveCBridgeable {
    associatedtype BridgedType: Bridged
    static var isBridged: Bool { get }
    
    var bridged: BridgedType { get }
    init(from: BridgedType)
}

public extension Bridgeable where BridgedType.Bridging == Self {
    typealias _ObjectiveCType = BridgedType
    static var isBridged: Bool { return true }
    static func _isBridgedToObjectiveC() -> Bool {
        return true
    }
    
    func _bridgeToObjectiveC() -> BridgedType {
        return BridgedType(self)
    }
    
    var bridged: BridgedType { return _bridgeToObjectiveC() }
    
    static func _forceBridgeFromObjectiveC<T: Bridged>(_ source: T, result: inout Self?) {
        result = (source.backing as! Self)
    }
    static func _conditionallyBridgeFromObjectiveC<T: Bridged>(_ source: T, result: inout Self?) -> Bool {
        result = _unconditionallyBridgeFromObjectiveC(source)
        return true
    }
    static func _unconditionallyBridgeFromObjectiveC<T: Bridged>(_ source: T?) -> Self {
        return source!.backing as! Self
    }
}

