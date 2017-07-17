import XCTest
@testable import KituraTests

XCTMain([
    testCase(KituraTests.allTests),
    testCase(RouterTests.allTests),
    testCase(ParameterParsingTests.allTests),
    testCase(FileServerTests.allTests)
])
