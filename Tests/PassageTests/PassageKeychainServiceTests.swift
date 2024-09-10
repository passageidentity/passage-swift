import XCTest
@testable import Passage

final class PassageKeychainServiceTests: XCTestCase {
    
    func testAddAndReadKeychainItem() {
        DispatchQueue.main.async {
            let key = "\(Date().timeIntervalSince1970)"
            let value = "TEST_VALUE"
            let keychainService = PassageKeychainService()
            XCTAssertNil(keychainService.getString(key: key))
            keychainService.addString(key: key, value: value)
            XCTAssertEqual(value, keychainService.getString(key: key))
            keychainService.deleteString(key: key)
        }
    }
    
    func testUpdateKeychainItem() {
        DispatchQueue.main.async {
            let key = "\(Date().timeIntervalSince1970)"
            let valueOne = "TEST_VALUE_ONE"
            let valueTwo = "TEST_VALUE_TWO"
            let keychainService = PassageKeychainService()
            XCTAssertNil(keychainService.getString(key: key))
            keychainService.addString(key: key, value: valueOne)
            XCTAssertEqual(valueOne, keychainService.getString(key: key))
            keychainService.updateString(key: key, value: valueTwo)
            XCTAssertEqual(valueTwo, keychainService.getString(key: key))
            keychainService.deleteString(key: key)
        }
    }
    
    func testDeleteKeychainItem() {
        DispatchQueue.main.async {
            let key = "\(Date().timeIntervalSince1970)"
            let value = "TEST_VALUE"
            let keychainService = PassageKeychainService()
            XCTAssertNil(keychainService.getString(key: key))
            keychainService.addString(key: key, value: value)
            XCTAssertEqual(value, keychainService.getString(key: key))
            keychainService.deleteString(key: key)
            XCTAssertNil(keychainService.getString(key: key))
        }
    }
    
}
