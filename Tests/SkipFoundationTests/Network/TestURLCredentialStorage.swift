// Copyright 2023–2025 Skip
// SPDX-License-Identifier: LGPL-3.0-only WITH LGPL-3.0-linking-exception
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import XCTest

#if !SKIP // disabled for to reduce test count and avoid io.grpc.StatusRuntimeException: RESOURCE_EXHAUSTED: gRPC message exceeds maximum size

// These tests are adapted from https://github.com/apple/swift-corelibs-foundation/blob/main/Tests/Foundation/Tests which have the following license:


// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2015 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//

class TestURLCredentialStorage : XCTestCase {

    func test_storageStartsEmpty() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let storage = URLCredentialStorage.shared
//        XCTAssertEqual(storage.allCredentials.count, 0)
        #endif // !SKIP
    }

    func test_sessionCredentialGetsReturnedForTheRightProtectionSpace() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let storage = URLCredentialStorage.shared

        let credential = URLCredential(user: "user1", password: "password1", persistence: .forSession)
        let space = URLProtectionSpace(host: "example.com", port: 0, protocol: NSURLProtectionSpaceHTTP, realm: nil, authenticationMethod: NSURLAuthenticationMethodDefault)

        expectChanges(storage.allCredentials.count, by: 1) {
            storage.set(credential, for: space)
        }
        XCTAssertEqual(storage.credentials(for: space)?.count, 1)

        guard let credentials = storage.credentials(for: space),
              let recovered = credentials[try XCTUnwrap(credential.user)] else {
            XCTFail("Credential not found in storage")
            return
        }
        XCTAssertEqual(recovered, credential)

        storage.remove(credential, for: space)
        #endif // !SKIP
    }

    func test_sessionCredentialDoesNotGetReturnedForTheWrongProtectionSpace() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let storage = URLCredentialStorage.shared

        let credential = URLCredential(user: "user1", password: "password1", persistence: .forSession)
        let space = URLProtectionSpace(host: "example.com", port: 0, protocol: NSURLProtectionSpaceHTTP, realm: nil, authenticationMethod: NSURLAuthenticationMethodDefault)
        let wrongSpace = URLProtectionSpace(host: "example2.com", port: 0, protocol: NSURLProtectionSpaceHTTP, realm: nil, authenticationMethod: NSURLAuthenticationMethodDefault)

        storage.set(credential, for: space)
        XCTAssertNil(storage.credentials(for: wrongSpace))

        storage.remove(credential, for: space)
        #endif // !SKIP
    }

    func test_sessionCredentialBecomesDefaultForProtectionSpace() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let storage = URLCredentialStorage.shared

        let credential = URLCredential(user: "user1", password: "password1", persistence: .forSession)
        let space = URLProtectionSpace(host: "example.com", port: 0, protocol: NSURLProtectionSpaceHTTP, realm: nil, authenticationMethod: NSURLAuthenticationMethodDefault)

        storage.set(credential, for: space)
        XCTAssertEqual(storage.defaultCredential(for: space), credential)

        storage.remove(credential, for: space)
        #endif // !SKIP
    }

    func test_sessionCredentialGetsReturnedAsDefaultIfSetAsDefaultForSpace() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let storage = URLCredentialStorage.shared

        let credential = URLCredential(user: "user1", password: "password1", persistence: .forSession)
        let space = URLProtectionSpace(host: "example.com", port: 0, protocol: NSURLProtectionSpaceHTTP, realm: nil, authenticationMethod: NSURLAuthenticationMethodDefault)

        storage.setDefaultCredential(credential, for: space)
        XCTAssertEqual(storage.defaultCredential(for: space), credential)

        storage.remove(credential, for: space)
        #endif // !SKIP
    }

    func test_sessionCredentialGetsReturnedIfSetAsDefaultForSpace() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let storage = URLCredentialStorage.shared

        let credential = URLCredential(user: "user1", password: "password1", persistence: .forSession)
        let space = URLProtectionSpace(host: "example.com", port: 0, protocol: NSURLProtectionSpaceHTTP, realm: nil, authenticationMethod: NSURLAuthenticationMethodDefault)

        expectChanges(storage.allCredentials.count, by: 1) {
            storage.setDefaultCredential(credential, for: space)
        }
        XCTAssertEqual(storage.credentials(for: space)?.count, 1)

        guard let credentials = storage.credentials(for: space),
              let recovered = credentials[try XCTUnwrap(credential.user)] else {
            XCTFail("Credential not found in storage")
            return
        }
        XCTAssertEqual(recovered, credential)

        storage.remove(credential, for: space)
        #endif // !SKIP
    }

    func test_sessionCredentialDoesNotGetReturnedIfSetAsDefaultForOtherSpace() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let storage = URLCredentialStorage.shared

        let credential = URLCredential(user: "user1", password: "password1", persistence: .forSession)
        let space = URLProtectionSpace(host: "example.com", port: 0, protocol: NSURLProtectionSpaceHTTP, realm: nil, authenticationMethod: NSURLAuthenticationMethodDefault)
        let wrongSpace = URLProtectionSpace(host: "example2.com", port: 0, protocol: NSURLProtectionSpaceHTTP, realm: nil, authenticationMethod: NSURLAuthenticationMethodDefault)

        storage.setDefaultCredential(credential, for: space)
        XCTAssertNil(storage.defaultCredential(for: wrongSpace))

        storage.remove(credential, for: space)
        #endif // !SKIP
    }

    func test_sessionCredentialDoesNotGetReturnedWhenNotAddedAsDefault() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let storage = URLCredentialStorage.shared

        let credential1 = URLCredential(user: "user1", password: "password1", persistence: .forSession)
        let credential2 = URLCredential(user: "user2", password: "password2", persistence: .forSession)
        let space = URLProtectionSpace(host: "example.com", port: 0, protocol: NSURLProtectionSpaceHTTP, realm: nil, authenticationMethod: NSURLAuthenticationMethodDefault)

        storage.set(credential2, for: space)
        storage.setDefaultCredential(credential1, for: space)
        XCTAssertNotEqual(storage.defaultCredential(for: space), credential2)

        storage.remove(credential2, for: space)
        storage.remove(credential1, for: space)
        #endif // !SKIP
    }

    func test_sessionCredentialCanBeRemovedFromSpace() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let storage = URLCredentialStorage.shared

        let credential = URLCredential(user: "user1", password: "password1", persistence: .forSession)
        let space = URLProtectionSpace(host: "example.com", port: 0, protocol: NSURLProtectionSpaceHTTP, realm: nil, authenticationMethod: NSURLAuthenticationMethodDefault)

        storage.set(credential, for: space)
        expectChanges(storage.allCredentials.count, by: -1) {
            storage.remove(credential, for: space)
        }
        XCTAssertNil(storage.credentials(for: space))

        storage.remove(credential, for: space)
        #endif // !SKIP
    }

    func test_sessionDefaultCredentialCanBeRemovedFromSpace() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let storage = URLCredentialStorage.shared

        let credential1 = URLCredential(user: "user1", password: "password1", persistence: .forSession)
        let credential2 = URLCredential(user: "user2", password: "password2", persistence: .forSession)
        let space = URLProtectionSpace(host: "example.com", port: 0, protocol: NSURLProtectionSpaceHTTP, realm: nil, authenticationMethod: NSURLAuthenticationMethodDefault)

        storage.setDefaultCredential(credential1, for: space)
        storage.set(credential2, for: space)
        storage.remove(credential1, for: space)
        XCTAssertNil(storage.defaultCredential(for: space))
        XCTAssertEqual(storage.credentials(for: space)?.count, 1)

        storage.remove(credential2, for: space)
        #endif // !SKIP
    }

    #if NS_FOUNDATION_NETWORKING_URLCREDENTIALSTORAGE_SYNCHRONIZABLE_ALLOWED
    /*
     swift-corelibs-foundation does not support synchronizable credentials, refusing to save them much like Darwin when logged out of iCloud.
     Thus, these tests cannot succeed — there is never a credential to remove.
     If we ever implement synchronizable credentials, uncomment this.
     */
    func test_synchronizableCredentialCanBeRemovedWithRightOptions() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let storage = URLCredentialStorage.shared

        let credential = URLCredential(user: "user1", password: "password1", persistence: .synchronizable)
        let space = URLProtectionSpace(host: "example.com", port: 0, protocol: NSURLProtectionSpaceHTTP, realm: nil, authenticationMethod: NSURLAuthenticationMethodDefault)

        storage.set(credential, for: space)
        expectChanges(storage.allCredentials.count, by: -1) {
            storage.remove(credential, for: space, options: [NSURLCredentialStorageRemoveSynchronizableCredentials: NSNumber(value: true)])
        }
        #endif // !SKIP
    }
    
    func test_synchronizableCredentialWillNotBeRemovedWithoutRightOptions() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let storage = URLCredentialStorage.shared

        let credential = URLCredential(user: "user1", password: "password1", persistence: .synchronizable)
        let space = URLProtectionSpace(host: "example.com", port: 0, protocol: NSURLProtectionSpaceHTTP, realm: nil, authenticationMethod: NSURLAuthenticationMethodDefault)

        storage.set(credential, for: space)

        // No options, no removal of synchronizable credentials
        storage.remove(credential, for: space)
        XCTAssertEqual(storage.allCredentials.count, 1)

        // Empty options, no removal of synchronizable credentials
        storage.remove(credential, for: space, options: [:])
        XCTAssertEqual(storage.allCredentials.count, 1)

        // Invalid type, no removal of synchronizable credentials
        storage.remove(credential, for: space, options: [NSURLCredentialStorageRemoveSynchronizableCredentials: "of course" as NSString])
        XCTAssertEqual(storage.allCredentials.count, 1)

        // False value, no removal of synchronizable credentials
        storage.remove(credential, for: space, options: [NSURLCredentialStorageRemoveSynchronizableCredentials: NSNumber(value: false)])
        XCTAssertEqual(storage.allCredentials.count, 1)

        storage.remove(credential, for: space, options: [NSURLCredentialStorageRemoveSynchronizableCredentials: NSNumber(value: true)])
        #endif // !SKIP
    }
    #endif
    
    func test_storageCanRemoveArbitraryCredentialWithoutFailing() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let storage = URLCredentialStorage.shared

        let credential1 = URLCredential(user: "user1", password: "password1", persistence: .forSession)
        let credential2 = URLCredential(user: "user2", password: "password2", persistence: .forSession)
        let space = URLProtectionSpace(host: "example.com", port: 0, protocol: NSURLProtectionSpaceHTTP, realm: nil, authenticationMethod: NSURLAuthenticationMethodDefault)

        storage.set(credential2, for: space)
        XCTAssertNoThrow(storage.remove(credential1, for: space))

        storage.remove(credential2, for: space)
        #endif // !SKIP
    }

    func test_storageWillNotSaveCredentialsWithoutPersistence() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let storage = URLCredentialStorage.shared

        let credential = URLCredential(user: "user1", password: "password1", persistence: .none)
        let space = URLProtectionSpace(host: "example.com", port: 0, protocol: NSURLProtectionSpaceHTTP, realm: nil, authenticationMethod: NSURLAuthenticationMethodDefault)

        expectNoChanges(storage.allCredentials.count) {
            storage.set(credential, for: space)
        }

        storage.remove(credential, for: space)
        #endif // !SKIP
    }

    // TODO: test that credentials without name/password are not saved. There's
    // no support for other kind of credentials, so it cannot be tested right
    // now.

    // TODO: test that credentials without name/password can be set as default.
    // There's no support for other kinds of credentials, so it cannot be tested
    // right now.

    func test_storageWillSendNotificationWhenAddingNewCredential() {
//        let storage = URLCredentialStorage.shared
//
//        let credential = URLCredential(user: "user1", password: "password1", persistence: .forSession)
//        let space = URLProtectionSpace(host: "example.com", port: 0, protocol: NSURLProtectionSpaceHTTP, realm: nil, authenticationMethod: NSURLAuthenticationMethodDefault)
//
//        let notificationReceived = expectation(description: "Notification Received")
//        let observer = NotificationCenter.default.addObserver(forName: .NSURLCredentialStorageChanged, object: storage, queue: nil) { _ in
//            notificationReceived.fulfill()
//        }
//
//        storage.set(credential, for: space)
//        waitForExpectations(timeout: 0)
//
//        NotificationCenter.default.removeObserver(observer)
//        storage.remove(credential, for: space)
    }

    func test_storageWillSendNotificationWhenAddingExistingCredentialToDifferentSpace() {
//        let storage = URLCredentialStorage.shared
//
//        let credential = URLCredential(user: "user1", password: "password1", persistence: .forSession)
//        let space1 = URLProtectionSpace(host: "example1.com", port: 0, protocol: NSURLProtectionSpaceHTTP, realm: nil, authenticationMethod: NSURLAuthenticationMethodDefault)
//        let space2 = URLProtectionSpace(host: "example2.com", port: 0, protocol: NSURLProtectionSpaceHTTP, realm: nil, authenticationMethod: NSURLAuthenticationMethodDefault)
//
//        storage.set(credential, for: space1)
//
//        let notificationReceived = expectation(description: "Notification Received")
//        let observer = NotificationCenter.default.addObserver(forName: .NSURLCredentialStorageChanged, object: storage, queue: nil) { _ in
//            notificationReceived.fulfill()
//        }
//
//        storage.set(credential, for: space2)
//        waitForExpectations(timeout: 0)
//
//        NotificationCenter.default.removeObserver(observer)
//        storage.remove(credential, for: space1)
//        storage.remove(credential, for: space2)
    }

    func test_storageWillNotSendNotificationWhenAddingExistingCredential() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let storage = URLCredentialStorage.shared

        let credential1 = URLCredential(user: "user1", password: "password1", persistence: .forSession)
        let credential2 = URLCredential(user: "user1", password: "password1", persistence: .forSession) // intentially equal
        let space = URLProtectionSpace(host: "example.com", port: 0, protocol: NSURLProtectionSpaceHTTP, realm: nil, authenticationMethod: NSURLAuthenticationMethodDefault)

        storage.set(credential1, for: space)

        let notificationReceived = expectation(description: "Notification Received")
        notificationReceived.isInverted = true
        let observer = NotificationCenter.default.addObserver(forName: .NSURLCredentialStorageChanged, object: storage, queue: nil) { _ in
            notificationReceived.fulfill()
        }

        storage.set(credential2, for: space)
        waitForExpectations(timeout: 0)

        NotificationCenter.default.removeObserver(observer)
        storage.remove(credential1, for: space)
        storage.remove(credential2, for: space)
        #endif // !SKIP
    }

    func test_storageWillSendNotificationWhenAddingNewDefaultCredential() {
//        let storage = URLCredentialStorage.shared
//
//        let credential = URLCredential(user: "user1", password: "password1", persistence: .forSession)
//        let space = URLProtectionSpace(host: "example.com", port: 0, protocol: NSURLProtectionSpaceHTTP, realm: nil, authenticationMethod: NSURLAuthenticationMethodDefault)
//
//        let notificationReceived = expectation(description: "Notification Received")
//        let observer = NotificationCenter.default.addObserver(forName: .NSURLCredentialStorageChanged, object: storage, queue: nil) { _ in
//            notificationReceived.fulfill()
//        }
//
//        storage.setDefaultCredential(credential, for: space)
//        waitForExpectations(timeout: 0)
//
//        NotificationCenter.default.removeObserver(observer)
//        storage.remove(credential, for: space)
    }

    func test_storageWillNotSendNotificationWhenAddingExistingDefaultCredential() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let storage = URLCredentialStorage.shared

        let credential1 = URLCredential(user: "user1", password: "password1", persistence: .forSession)
        let credential2 = URLCredential(user: "user1", password: "password1", persistence: .forSession) // intentionally equal
        let space = URLProtectionSpace(host: "example.com", port: 0, protocol: NSURLProtectionSpaceHTTP, realm: nil, authenticationMethod: NSURLAuthenticationMethodDefault)

        storage.setDefaultCredential(credential1, for: space)

        let notificationReceived = expectation(description: "Notification Received")
        notificationReceived.isInverted = true
        let observer = NotificationCenter.default.addObserver(forName: .NSURLCredentialStorageChanged, object: storage, queue: nil) { _ in
            notificationReceived.fulfill()
        }

        storage.setDefaultCredential(credential2, for: space)
        waitForExpectations(timeout: 0)

        NotificationCenter.default.removeObserver(observer)
        storage.remove(credential1, for: space)
        storage.remove(credential2, for: space)
        #endif // !SKIP
    }

    func test_storageWillSendNotificationWhenAddingDifferentDefaultCredential() {
//        let storage = URLCredentialStorage.shared
//
//        let credential1 = URLCredential(user: "user1", password: "password1", persistence: .forSession)
//        let credential2 = URLCredential(user: "user2", password: "password2", persistence: .forSession)
//        let space = URLProtectionSpace(host: "example.com", port: 0, protocol: NSURLProtectionSpaceHTTP, realm: nil, authenticationMethod: NSURLAuthenticationMethodDefault)
//
//        storage.setDefaultCredential(credential1, for: space)
//
//        let notificationReceived = expectation(description: "Notification Received")
//        let observer = NotificationCenter.default.addObserver(forName: .NSURLCredentialStorageChanged, object: storage, queue: nil) { _ in
//            notificationReceived.fulfill()
//        }
//
//        storage.setDefaultCredential(credential2, for: space)
//        waitForExpectations(timeout: 0)
//
//        NotificationCenter.default.removeObserver(observer)
//        storage.remove(credential1, for: space)
//        storage.remove(credential2, for: space)
    }

    func test_storageWillSendNotificationWhenRemovingExistingCredential() {
//        let storage = URLCredentialStorage.shared
//
//        let credential = URLCredential(user: "user1", password: "password1", persistence: .forSession)
//        let space = URLProtectionSpace(host: "example.com", port: 0, protocol: NSURLProtectionSpaceHTTP, realm: nil, authenticationMethod: NSURLAuthenticationMethodDefault)
//
//        storage.set(credential, for: space)
//
//        let notificationReceived = expectation(description: "Notification Received")
//        let observer = NotificationCenter.default.addObserver(forName: .NSURLCredentialStorageChanged, object: storage, queue: nil) { _ in
//            notificationReceived.fulfill()
//        }
//
//        storage.remove(credential, for: space)
//        waitForExpectations(timeout: 0)
//
//        NotificationCenter.default.removeObserver(observer)
//        storage.remove(credential, for: space)
    }

    func test_storageWillNotSendNotificationWhenRemovingExistingCredentialInOtherSpace() {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let storage = URLCredentialStorage.shared

        let credential = URLCredential(user: "user1", password: "password1", persistence: .forSession)
        let space1 = URLProtectionSpace(host: "example1.com", port: 0, protocol: NSURLProtectionSpaceHTTP, realm: nil, authenticationMethod: NSURLAuthenticationMethodDefault)
        let space2 = URLProtectionSpace(host: "example2.com", port: 0, protocol: NSURLProtectionSpaceHTTP, realm: nil, authenticationMethod: NSURLAuthenticationMethodDefault)

        storage.set(credential, for: space1)

        let notificationReceived = expectation(description: "Notification Received")
        notificationReceived.isInverted = true
        let observer = NotificationCenter.default.addObserver(forName: .NSURLCredentialStorageChanged, object: storage, queue: nil) { _ in
            notificationReceived.fulfill()
        }

        storage.remove(credential, for: space2)
        waitForExpectations(timeout: 0)

        NotificationCenter.default.removeObserver(observer)
        storage.remove(credential, for: space1)
        #endif // !SKIP
    }

    func test_storageWillSendNotificationWhenRemovingDefaultNotification() {
//        let storage = URLCredentialStorage.shared
//
//        // TODO: this test will be better is we can create credentials without
//        // user/password, but currently is not possible. At least we are testing
//        // that only one notification is fired.
//        let credential = URLCredential(user: "user1", password: "password1", persistence: .forSession)
//        let space = URLProtectionSpace(host: "example.com", port: 0, protocol: NSURLProtectionSpaceHTTP, realm: nil, authenticationMethod: NSURLAuthenticationMethodDefault)
//
//        storage.setDefaultCredential(credential, for: space)
//
//        let notificationReceived = expectation(description: "Notification Received")
//        let observer = NotificationCenter.default.addObserver(forName: .NSURLCredentialStorageChanged, object: storage, queue: nil) { _ in
//            notificationReceived.fulfill()
//        }
//        defer { NotificationCenter.default.removeObserver(observer) }
//
//        storage.remove(credential, for: space)
//        waitForExpectations(timeout: 0)
    }

    func test_taskBasedGetCredentialsReturnsCredentialsForSpace() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let storage = URLCredentialStorage.shared

        let credential = URLCredential(user: "user1", password: "password1", persistence: .forSession)
        let space = URLProtectionSpace(host: "example.com", port: 0, protocol: NSURLProtectionSpaceHTTP, realm: nil, authenticationMethod: NSURLAuthenticationMethodDefault)

        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: try XCTUnwrap(URL(string: "http://example.com/")))

        storage.set(credential, for: space)

        let completionCallbackCalled = expectation(description: "Completion callback called")
        storage.getCredentials(for: space, task: task) { credentials in
            completionCallbackCalled.fulfill()
            XCTAssertNotNil(credentials)
            XCTAssertEqual(credentials?["user1"], credential)
        }

        waitForExpectations(timeout: 0)

        storage.remove(credential, for: space)
        #endif // !SKIP
    }

    func test_taskBasedSetCredentialStoresGivenCredentials() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let storage = URLCredentialStorage.shared

        let credential = URLCredential(user: "user1", password: "password1", persistence: .forSession)
        let space = URLProtectionSpace(host: "example.com", port: 0, protocol: NSURLProtectionSpaceHTTP, realm: nil, authenticationMethod: NSURLAuthenticationMethodDefault)

        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: try XCTUnwrap(URL(string: "http://example.com/")))

        storage.set(credential, for: space, task: task)

        let expectation = self.expectation(description: "Done")
        
        storage.getCredentials(for: space, task: task) { credentials in
            guard let credentials = credentials,
                  let user = credential.user,
                  let recovered = credentials[user] else {
                    XCTFail("Credential not found in storage")
                    return
            }
            XCTAssertEqual(recovered, credential)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10)
        storage.remove(credential, for: space)
        #endif // !SKIP
    }

    func test_taskBasedRemoveCredentialDeletesCredentialsFromSpace() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let storage = URLCredentialStorage.shared

        let credential = URLCredential(user: "user1", password: "password1", persistence: .forSession)
        let space = URLProtectionSpace(host: "example.com", port: 0, protocol: NSURLProtectionSpaceHTTP, realm: nil, authenticationMethod: NSURLAuthenticationMethodDefault)

        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: try XCTUnwrap(URL(string: "http://example.com/")))

        storage.set(credential, for: space)

        expectChanges(storage.allCredentials.count, by: -1) {
            storage.remove(credential, for: space, options: [:], task: task)
        }
        #endif // !SKIP
    }

    func test_taskBasedGetDefaultCredentialReturnsTheDefaultCredential() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let storage = URLCredentialStorage.shared

        let credential = URLCredential(user: "user1", password: "password1", persistence: .forSession)
        let space = URLProtectionSpace(host: "example.com", port: 0, protocol: NSURLProtectionSpaceHTTP, realm: nil, authenticationMethod: NSURLAuthenticationMethodDefault)

        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: try XCTUnwrap(URL(string: "http://example.com/")))

        storage.setDefaultCredential(credential, for: space)

        let completionCallbackCalled = expectation(description: "Completion callback called")
        storage.getDefaultCredential(for: space, task: task) {
            completionCallbackCalled.fulfill()
            XCTAssertEqual($0, credential)
        }

        waitForExpectations(timeout: 0)

        storage.remove(credential, for: space)
        #endif // !SKIP
    }

    func test_taskBasedSetDefaultCredentialStoresTheDefaultCredential() throws {
        #if SKIP
        throw XCTSkip("TODO")
        #else
        let storage = URLCredentialStorage.shared

        let credential = URLCredential(user: "user1", password: "password1", persistence: .forSession)
        let space = URLProtectionSpace(host: "example.com", port: 0, protocol: NSURLProtectionSpaceHTTP, realm: nil, authenticationMethod: NSURLAuthenticationMethodDefault)

        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: try XCTUnwrap(URL(string: "http://example.com/")))

        expectChanges(storage.allCredentials.count, by: 1) {
            storage.setDefaultCredential(credential, for: space, task: task)
        }

        XCTAssertEqual(storage.defaultCredential(for: space), credential)

        storage.remove(credential, for: space)
        #endif // !SKIP
    }
    
    
}

#endif

