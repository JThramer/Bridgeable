import XCTest
@testable import Bridgeable

class BridgeableTests: XCTestCase {
    
    func testForwards() {
        var subject = SomeStruct()
        subject.someEnum = .three
        let casted = subject as MBXObject
        XCTAssert(casted.testIdentifier.isEqual(to: "three"), "Expected backing to reflect correct value")
        subject.someEnum = .five
        XCTAssert(casted.testIdentifier.isEqual(to: "three"), "casted is acting like an object")
        XCTAssert(subject.bridged.testIdentifier.isEqual(to: "five"), "called bridged again should be correct value")
    }
    
    func testBackwards() {
        let objCSubject = MBXObject()
        objCSubject.testIdentifier = "four"
        let subject = objCSubject as SomeStruct
        XCTAssert(subject.someEnum == .four, "expected casted swift object to reflect correct value")
        
    }
    
    func testOBJCObjectBehavesNormally() {
        let objCSubject = MBXObject()
        XCTAssert(objCSubject.testIdentifier == "none", "Bridged subject didn't take on struct's initial test value")
        objCSubject.testIdentifier = "three"
        XCTAssert(objCSubject.testIdentifier == "three", "Basic get/set behavior not working")
        objCSubject.testIdentifier = "five"
        XCTAssert(objCSubject.testIdentifier == "five", "problems changing values")
    }
    
}
//MARK: - Mock Data Structures
enum SomeEnumType: String {
    case none, one, two, three, four, five
}

struct SomeStruct: Bridgeable {

    static var isBridged: Bool = true
    
    typealias Bridged = MBXObject
    
    var someEnum: SomeEnumType = .none
    
    init(){}
    
    init(from bridged: SomeStruct.Bridged) {
        self.someEnum = SomeEnumType(rawValue: bridged.testIdentifier as String)!
    }
}

@objc class MBXdObject: NSObject, Bridged {
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
            return backing.someEnum.rawValue as NSString
        }
        set {
            backing.someEnum = SomeEnumType(rawValue: newValue as String)!
        }
    }
}
