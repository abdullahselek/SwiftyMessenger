//
//  MessengerFileTransitingTests.swift
//  SwiftyMessengerTests
//
//  Created by Abdullah Selek on 16.05.18.
//  Copyright © 2018 Abdullah Selek. All rights reserved.
//

import XCTest

@testable import SwiftyMessenger

class MessengerFileTransitingTests: XCTestCase {
    
    var fileTransiting: MessengerFileTransiting!
    
    override func setUp() {
        super.setUp()
        fileTransiting = MessengerFileTransiting(withApplicationGroupIdentifier: "com.abdullahselek.SwiftyGroup", directory: "tests")
    }
    
    func testInit() {
        XCTAssertNotNil(MessengerFileTransiting(), "MessengerFileTransiting default initialization failed!")
    }
    
    func testInitWithParameter() {
        XCTAssertNotNil(fileTransiting, "MessengerFileTransiting initialization with parameters failed!")
    }
    
    func testMessagePassingDirectoryPath() {
        XCTAssertNil(fileTransiting.messagePassingDirectoryPath())
    }
    
    func testFilePath_whenIdentifierEmpty() {
        XCTAssertNil(fileTransiting.filePath(forIdentifier: ""))
    }
    
    func testFilePath_whenIdentifierNotEmpty() {
        // because of testing framework there is no app group available
        XCTAssertNil(fileTransiting.filePath(forIdentifier: "file1"))
    }
    
    override func tearDown() {
        fileTransiting = nil
        super.tearDown()
    }
    
}

