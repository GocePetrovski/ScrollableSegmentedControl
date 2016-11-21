//
//  TableViewController.swift
//  ScrollableSegmentedControlDemo
//
//  Created by Goce Petrovski on 11/11/16.
//  Copyright © 2016 Pomarium. All rights reserved.
//

import UIKit
import ScrollableSegmentedControl

class TableViewController: UITableViewController {

    @IBOutlet weak var segmentedControl: ScrollableSegmentedControl!
    
    var selectedIndexPath = IndexPath(row: 0, section: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        segmentedControl.segmentStyle = .textOnly
        segmentedControl.insertSegment(withTitle: "Segment 1", image: #imageLiteral(resourceName: "segment-1"), at: 0)
        segmentedControl.insertSegment(withTitle: "Segment 2", image: #imageLiteral(resourceName: "segment-2"), at: 1)
        segmentedControl.insertSegment(withTitle: "Segment 3", image: #imageLiteral(resourceName: "segment-3"), at: 2)
        segmentedControl.insertSegment(withTitle: "Segment 4", image: #imageLiteral(resourceName: "segment-4"), at: 3)
        segmentedControl.insertSegment(withTitle: "Segment 5", image: #imageLiteral(resourceName: "segment-5"), at: 4)
        segmentedControl.insertSegment(withTitle: "Segment 6", image: #imageLiteral(resourceName: "segment-6"), at: 5)
        
        segmentedControl.underlineSelected = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let cell = tableView.cellForRow(at: selectedIndexPath) {
            cell.accessoryType = .none
        }
        selectedIndexPath = indexPath
        if let cell = tableView.cellForRow(at: selectedIndexPath) {
            cell.accessoryType = .checkmark
        }
        
        switch indexPath.row {
        case 0:
            segmentedControl.segmentStyle = .textOnly
        case 1:
            segmentedControl.segmentStyle = .imageOnly
        case 2:
            segmentedControl.segmentStyle = .imageOnTop
        case 3:
            segmentedControl.segmentStyle = .imageOnLeft
        default: break
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
