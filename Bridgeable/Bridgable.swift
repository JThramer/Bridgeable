import Foundation

public protocol BridgeableType: AnyObject {
    associatedtype Bridging
    
    var backing: Bridging { get }
    
    init(_ backing: Bridging)
}

public protocol Bridgeable: _ObjectiveCBridgeable {
    associatedtype Bridged: BridgeableType
    static var isBridged: Bool { get }
    
    var bridged: Bridged { get }
    init(from: Bridged)
}

public extension Bridgeable where Bridged.Bridging == Self {
    static func _isBridgedToObjectiveC() -> Bool {
        return true
    }
    
    func _bridgeToObjectiveC() -> Bridged {
        return Bridged(self)
    }
    
    var bridged: Bridged { return _bridgeToObjectiveC() }
    
    func toBridgedObject() -> Bridged {
        return _bridgeToObjectiveC()
    }
    static func _forceBridgeFromObjectiveC<T: BridgeableType>(_ source: T, result: inout Self?) {
        result = (source.backing as! Self)
    }
    static func _conditionallyBridgeFromObjectiveC<T: BridgeableType>(_ source: T, result: inout Self?) -> Bool {
        result = _unconditionallyBridgeFromObjectiveC(source)
        return true
    }
    static func _unconditionallyBridgeFromObjectiveC<T: BridgeableType>(_ source: T?) -> Self {
        return source!.backing as! Self
    }
}

