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
        segmentedControl.frame = CGRect(x: 0, y: 0, width: 320, height: 100)
        segmentedControl.layoutSubviews()
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
    
    func testSelectedIndex(){
        segmentedControl.insertSegment(withTitle: "segment 1", image: nil, at: 0)
        segmentedControl.insertSegment(withTitle: "segment 2", image: nil, at: 1)
        segmentedControl.insertSegment(withTitle: "segment 3", image: nil, at: 2)
        
        segmentedControl.underlineSelected = true
        segmentedControl.selectedSegmentIndex = 1
        
        XCTAssert(segmentedControl.selectedSegmentIndex == 1)
        
        let collectionView = segmentedControl.viewWithTag(1) as? UICollectionView
        XCTAssertNotNil(collectionView)
        let indexPath = collectionView!.indexPathsForSelectedItems?.last
        XCTAssert(indexPath?.item == 1)
    }
    
    func testUnderlineIsPresent(){
        segmentedControl.insertSegment(withTitle: "segment 1", image: nil, at: 0)
        segmentedControl.insertSegment(withTitle: "segment 2", image: nil, at: 1)
        segmentedControl.insertSegment(withTitle: "segment 3", image: nil, at: 2)
        
        let collectionView = segmentedControl.viewWithTag(1) as? UICollectionView
        XCTAssertNotNil(collectionView)
        
        segmentedControl.underlineSelected = true
        segmentedControl.selectedSegmentIndex = 1
        
       
        let indexPath = collectionView!.indexPathsForSelectedItems?.last
        XCTAssertNotNil(indexPath)
        let cell = collectionView?.dataSource?.collectionView(collectionView!, cellForItemAt: indexPath!)
        XCTAssertNotNil(cell)
        
        let underlineView = cell?.contentView.viewWithTag(999)
        XCTAssertNotNil(underlineView)
    }
    
    func testTintColor(){
        segmentedControl.insertSegment(withTitle: "segment 1", image: nil, at: 0)
        segmentedControl.insertSegment(withTitle: "segment 2", image: nil, at: 1)
        segmentedControl.insertSegment(withTitle: "segment 3", image: nil, at: 2)
        
        let collectionView = segmentedControl.viewWithTag(1) as? UICollectionView
        segmentedControl.underlineSelected = true
        segmentedControl.selectedSegmentIndex = 1
        
        let indexPath = collectionView!.indexPathsForSelectedItems?.last
        var cell = collectionView?.dataSource?.collectionView(collectionView!, cellForItemAt: indexPath!)
        var underlineView = cell?.contentView.viewWithTag(999)
        
        let color = UIColor.purple
        XCTAssertFalse(underlineView?.backgroundColor == color)
        
        segmentedControl.tintColor = color
        cell = collectionView?.dataSource?.collectionView(collectionView!, cellForItemAt: indexPath!)
        underlineView = cell?.contentView.viewWithTag(999)
        XCTAssertTrue(underlineView?.backgroundColor == color)
    }

    func testUnderlineHeight() {
        segmentedControl.insertSegment(withTitle: "segment 1", image: nil, at: 0)
        segmentedControl.underlineSelected = true
        segmentedControl.segmentStyle = .textOnly

        self.segmentedControl.underlineHeight = 3
        segmentedControl.selectedSegmentIndex = 0

        var collectionView = self.segmentedControl.viewWithTag(1) as? UICollectionView
        var indexPath = collectionView!.indexPathsForSelectedItems?.last
        var cell = collectionView?.dataSource?.collectionView(collectionView!, cellForItemAt: indexPath!)
        cell?.updateConstraints()
        var underlineView = cell?.contentView.viewWithTag(999)
        // The underline has only one constraint at its level, the height
        XCTAssertTrue(underlineView?.constraints.first?.constant == 3)

        self.segmentedControl.underlineHeight = 10

        collectionView = self.segmentedControl.viewWithTag(1) as? UICollectionView
        indexPath = collectionView!.indexPathsForSelectedItems?.last
        cell = collectionView?.dataSource?.collectionView(collectionView!, cellForItemAt: indexPath!)
        cell?.updateConstraints()
        underlineView = cell?.contentView.viewWithTag(999)
        // The underline has only one constraint at its level, the height
        XCTAssertTrue(underlineView?.constraints.first?.constant == 10)

    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
