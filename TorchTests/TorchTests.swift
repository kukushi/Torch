//
//  TorchTests.swift
//  TorchTests
//
//  Created by kukushi on 3/30/15.
//  Copyright (c) 2015 Xing He. All rights reserved.
//

import UIKit
import XCTest
@testable import Torch

class MockScrollView: UIScrollView {
    var mockedIsDragging = false
    override var isDragging: Bool {
        return mockedIsDragging
    }

    func offsetVertical(with length: CGFloat) {
        setContentOffset(CGPoint(x: 0, y: length), animated: false)
    }
}

class TorchTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testStateChanges() {
        let direction = PullDirection.down
        let scrollView = mockedScrollView(with: .down)

        XCTAssertEqual(scrollView.pullState(of: direction), .done)

        // Mock Dragging
        scrollView.mockedIsDragging = true
        scrollView.setContentOffset(CGPoint(x: 0, y: -20), animated: false)
        XCTAssertEqual(scrollView.pullState(of: direction), .pulling)

        // Dragging is done
        scrollView.mockedIsDragging = false
        scrollView.setContentOffset(CGPoint(x: 0, y: -21), animated: false)
        XCTAssertEqual(scrollView.pullState(of: direction), .done)

        scrollView.mockedIsDragging = true
        scrollView.setContentOffset(CGPoint(x: 0, y: -100), animated: false)
        XCTAssertEqual(scrollView.pullState(of: direction), .readyToRelease)

        scrollView.mockedIsDragging = false
        scrollView.setContentOffset(CGPoint(x: 0, y: -101), animated: false)
        XCTAssertEqual(scrollView.pullState(of: direction), .refreshing)

        scrollView.stopRefresh(direction, animated: false)
        XCTAssertEqual(scrollView.pullState(of: direction), .done)
    }

    func testStatesWithBothUpAndDown1() {
        let scrollView = mockedScrollView(with: .down)
        var option = PullOption()
        option.direction = .up
        scrollView.addPullToRefresh(option) { (_) in
            // ...
        }

        XCTAssertEqual(scrollView.pullState(of: .down), .done)
        XCTAssertEqual(scrollView.pullState(of: .up), .done)

        scrollView.mockedIsDragging = true
        let pullingOffset = scrollView.contentSize.height - scrollView.frame.height + 1
        scrollView.offsetVertical(with: pullingOffset)
        XCTAssertEqual(scrollView.pullState(of: .down), .done)
        XCTAssertEqual(scrollView.pullState(of: .up), .pulling)

        let readyToReleaseOffset = scrollView.contentSize.height - scrollView.frame.height + 200
        scrollView.offsetVertical(with: readyToReleaseOffset)
        XCTAssertEqual(scrollView.pullState(of: .down), .done)
        XCTAssertEqual(scrollView.pullState(of: .up), .readyToRelease)

        let contentInset = scrollView.contentInset
        scrollView.mockedIsDragging = false
        let triggeringOffset = scrollView.contentSize.height - scrollView.frame.height + 50
        scrollView.offsetVertical(with: triggeringOffset)
        XCTAssertEqual(scrollView.pullState(of: .down), .done)
        XCTAssertEqual(scrollView.pullState(of: .up), .refreshing)
        var refreshingContentInset = contentInset
        refreshingContentInset.bottom += option.areaHeight + option.topPadding
        XCTAssertEqual(scrollView.contentInset, refreshingContentInset)

        scrollView.stopRefresh(.up)
        XCTAssertEqual(scrollView.pullState(of: .down), .done)
        XCTAssertEqual(scrollView.pullState(of: .up), .done)
        XCTAssertEqual(scrollView.contentInset, contentInset)

        scrollView.stopRefresh(.down)
        XCTAssertEqual(scrollView.pullState(of: .down), .done)
        XCTAssertEqual(scrollView.pullState(of: .up), .done)
        XCTAssertEqual(scrollView.contentInset, contentInset)
    }

    func testStatesWithBothUpAndDown2() {
        let scrollView = mockedScrollView(with: .down)
        var option = PullOption()
        option.direction = .up
        scrollView.addPullToRefresh(option) { (_) in
            // ...
        }

        XCTAssertEqual(scrollView.pullState(of: .down), .done)
        XCTAssertEqual(scrollView.pullState(of: .up), .done)

        scrollView.mockedIsDragging = true
        let pullingOffset: CGFloat = -1
        scrollView.offsetVertical(with: pullingOffset)
        XCTAssertEqual(scrollView.pullState(of: .down), .pulling)
        XCTAssertEqual(scrollView.pullState(of: .up), .done)

        let readyToReleaseOffset: CGFloat = -200
        scrollView.offsetVertical(with: readyToReleaseOffset)
        XCTAssertEqual(scrollView.pullState(of: .down), .readyToRelease)
        XCTAssertEqual(scrollView.pullState(of: .up), .done)

        let contentInset = scrollView.contentInset
        scrollView.mockedIsDragging = false
        let triggeringOffset: CGFloat = -50
        scrollView.offsetVertical(with: triggeringOffset)
        XCTAssertEqual(scrollView.pullState(of: .down), .refreshing)
        XCTAssertEqual(scrollView.pullState(of: .up), .done)
        var refreshingContentInset = contentInset
        refreshingContentInset.top += option.areaHeight + option.topPadding
        XCTAssertEqual(scrollView.contentInset, refreshingContentInset)

        scrollView.stopRefresh(.down)
        XCTAssertEqual(scrollView.pullState(of: .down), .done)
        XCTAssertEqual(scrollView.pullState(of: .up), .done)
        XCTAssertEqual(scrollView.contentInset, contentInset)

        scrollView.stopRefresh(.up)
        XCTAssertEqual(scrollView.pullState(of: .down), .done)
        XCTAssertEqual(scrollView.pullState(of: .up), .done)
        XCTAssertEqual(scrollView.contentInset, contentInset)
    }

    func mockedScrollView(with direction: PullDirection) -> MockScrollView {
        let scrollView = MockScrollView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        scrollView.contentSize = CGSize(width: 100, height: 200)

        var option = PullOption()
        option.direction = direction
        scrollView.addPullToRefresh(option) { (_) in
            // ...
        }
        return scrollView
    }
}
