//
//  ScrollableSegmentedControlTests.swift
//  ScrollableSegmentedControlTests
//
//  Created by Goce Petrovski on 10/11/16.
//  Copyright © 2016 Pomarium. All rights reserved.
//

import XCTest
@testable import ScrollableSegmentedControl

class ScrollableSegmentedControlTests: XCTestCase {
    let segmentedControl = ScrollableSegmentedControl()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testNumberOfSegements() {
        segmentedControl.insertSegment(withTitle: "segment 1", image: nil, at: 0)
        segmentedControl.insertSegment(withTitle: "segment 2", image: nil, at: 0)
        
        XCTAssertTrue(segmentedControl.numberOfSegments == 2, "Number of segments should be 2")
        
        segmentedControl.removeSegment(at: 0)
        XCTAssertTrue(segmentedControl.numberOfSegments == 1, "Number of segments should be 1")
    }
    
    func testSegementTitleContent() {
        segmentedControl.insertSegment(withTitle: "segment 1", image: nil, at: 0)
        segmentedControl.insertSegment(withTitle: "segment 3", image: nil, at: 1)
        segmentedControl.insertSegment(withTitle: "segment 4", image: nil, at: 2)
        segmentedControl.insertSegment(withTitle: "segment 2", image: nil, at: 1)

        
        XCTAssertNotNil(segmentedControl.titleForSegment(at: 2))
        XCTAssert(segmentedControl.titleForSegment(at:2)?.compare("segment 3") == ComparisonResult.orderedSame, "Title should be segment 3")
        XCTAssertNotNil(segmentedControl.titleForSegment(at:-1))
        XCTAssert(segmentedControl.titleForSegment(at:-1)?.compare("segment 1") == ComparisonResult.orderedSame, "Title should be segment 1")
        XCTAssertNotNil(segmentedControl.titleForSegment(at:99))
        XCTAssert(segmentedControl.titleForSegment(at:99)?.compare("segment 4") == ComparisonResult.orderedSame, "Title should be segment 4")
        
        segmentedControl.removeSegment(at: 3)
        XCTAssert(segmentedControl.titleForSegment(at:99)?.compare("segment 3") == ComparisonResult.orderedSame, "Title should be segment 3")
    }
    
    func testInternalNumberOfSegements(){
        segmentedControl.insertSegment(withTitle: "segment 1", image: nil, at: 0)
        segmentedControl.insertSegment(withTitle: "segment 2", image: nil, at: 1)
        segmentedControl.insertSegment(withTitle: "segment 3", image: nil, at: 2)
        
        let collectionView = segmentedControl.subviews[0] as? UICollectionView
        XCTAssertNotNil(collectionView)
        
        XCTAssert(collectionView?.numberOfSections == 1)
        XCTAssert(collectionView?.numberOfItems(inSection: 0) == 3)
    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
