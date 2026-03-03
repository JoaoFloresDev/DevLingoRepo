import XCTest
@testable import DevLingo

final class DevLingoTests: XCTestCase {
    func testPhraseModelDecoding() throws {
        let json = """
        {"id":"test_001","english":"Hello","context":"Greeting","translations":{"pt-BR":"Olá"},"difficulty":"easy","category":"casual"}
        """.data(using: .utf8)!
        let phrase = try JSONDecoder().decode(Phrase.self, from: json)
        XCTAssertEqual(phrase.id, "test_001")
        XCTAssertEqual(phrase.english, "Hello")
    }
}
