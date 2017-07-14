import XCTest
@testable import Srt2BilibiliKit

class Srt2BilibiliKitTests: XCTestCase {

    func testVideoPageFetching() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let goal = expectation(description: "Video page information fetch")
        S2BVideo(av: 8993458).p1 { page in
            XCTAssertNotNil(page, "Failed to fetch pages of video")
            XCTAssertEqual(page!.cid, 14848859, "Wrong cid")
            goal.fulfill()
        }
        waitForExpectations(timeout: 20, handler: nil)
    }

    static let allTests = [
        ("testVideoPageFetching", testVideoPageFetching),
    ]
}
