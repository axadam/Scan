import XCTest

import ScanTests

var tests = [XCTestCaseEntry]()
tests += ScanTests.allTests()
XCTMain(tests)