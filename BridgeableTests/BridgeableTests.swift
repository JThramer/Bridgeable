import XCTest
@testable import Bridgeable

class BridgeableTests: XCTestCase {
    
    func testForwards() {
        var subject = SomeStruct()
        subject.someEnum = .three
        let casted = subject as MBXObject
        XCTAssert(casted.testIdentifier.isEqual(to: "three"), "Expected backing to ")
        subject.someEnum = .five
        XCTAssert(casted.testIdentifier.isEqual(to: "three"), "casted is acting like an object")
        XCTAssert(subject.bridged.testIdentifier.isEqual(to: "five"), "called bridged again should be ")
    }
    
    func testBackwards() {
        let objCSubject = MBXObject()
        objCSubject.testIdentifier = "four"
        let subject = objCSubject as SomeStruct
        XCTAssert(subject.someEnum == .four, "bloop")
        
    }
    
}

enum SomeEnumType: String {
    case none, one, two, three, four, five
}

struct SomeStruct: Bridgeable {

    static var isBridged: Bool = true
    
    typealias Bridged = MBXObject
    typealias _ObjectiveCType = MBXObject
    
    var someEnum: SomeEnumType = .none
    
    init(){}
    
    init(from bridged: SomeStruct.Bridged) {
        self.someEnum = SomeEnumType(rawValue: bridged.testIdentifier as String)!
    }
}
@objc class MBXObject: NSObject, BridgeableType {
    typealias Bridging = SomeStruct
    var backing: Bridging
    
    override init() {
        backing = SomeStruct()
        super.init()
    }
    required init(_ backingObject: SomeStruct) {
        self.backing = backingObject
    }

    var testIdentifier: NSString {
        get {
            let foo = backing.someEnum.rawValue as NSString
            return foo
        }
        set {
            backing.someEnum = SomeEnumType(rawValue: newValue as String)!
        }
    }
}
