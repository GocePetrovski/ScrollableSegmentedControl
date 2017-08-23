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
    @IBOutlet weak var removeSegmentButton: UIBarButtonItem!
    
    var selectedIndexPath = IndexPath(row: 0, section: 0)
    var selectedAttributesIndexPath = IndexPath(row: 0, section: 1)
    
    let largerRedTextAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 16),
                      NSForegroundColorAttributeName: UIColor.red]
    
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
        segmentedControl.selectedSegmentIndex = 0
        
        segmentedControl.addTarget(self, action: #selector(TableViewController.segmentSelected(sender:)), for: .valueChanged)
    }
    
    func segmentSelected(sender:ScrollableSegmentedControl) {
        print("Segment at index \(sender.selectedSegmentIndex)  selected")
    }

    @IBAction func addSegment(_ sender: Any) {
        let index = segmentedControl.numberOfSegments
        segmentedControl.insertSegment(withTitle: "Segment \(index + 1)", image: #imageLiteral(resourceName: "segment-6"), at: index)
    }
    
    @IBAction func removeSegment(_ sender: Any) {
        if segmentedControl.numberOfSegments > 6 {
            segmentedControl.removeSegment(at: segmentedControl.numberOfSegments - 1)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 1 {
            cell.textLabel!.attributedText = NSAttributedString(string: cell.textLabel!.text!, attributes: largerRedTextAttributes)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if let cell = tableView.cellForRow(at: selectedIndexPath) {
                cell.accessoryType = .none
            }
            selectedIndexPath = indexPath
            if let cell = tableView.cellForRow(at: selectedIndexPath) {
                cell.accessoryType = .checkmark
            }
            
            var height = 44
            switch indexPath.row {
            case 0:
                segmentedControl.segmentStyle = .textOnly
            case 1:
                segmentedControl.segmentStyle = .imageOnly
                height = 52
            case 2:
                segmentedControl.segmentStyle = .imageOnTop
                height = 60
            case 3:
                segmentedControl.segmentStyle = .imageOnLeft
            default: break
                
            }
            
            let headerView = tableView.tableHeaderView!
            tableView.tableHeaderView = nil
            var headerFrame = headerView.frame
            
            headerFrame.size.height =  CGFloat(height)
            headerView.frame = headerFrame
            tableView.tableHeaderView = headerView
        } else {
            if let cell = tableView.cellForRow(at: selectedAttributesIndexPath) {
                cell.accessoryType = .none
            }
            selectedAttributesIndexPath = indexPath
            if let cell = tableView.cellForRow(at: selectedAttributesIndexPath) {
                cell.accessoryType = .checkmark
            }
            
            switch indexPath.row {
            case 0:
                segmentedControl.setTitleTextAttributes(nil, for: .normal)
            case 1:
                let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 16),
                                  NSForegroundColorAttributeName: UIColor.red]
                segmentedControl.setTitleTextAttributes(attributes, for: .normal)
            default: break
                
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
