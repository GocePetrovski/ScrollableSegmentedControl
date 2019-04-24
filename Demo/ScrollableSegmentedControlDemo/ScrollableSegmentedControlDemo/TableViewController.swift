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
    @IBOutlet weak var fixedWidthSwitch: UISwitch!
    
    var selectedIndexPath = IndexPath(row: 0, section: 0)
    var selectedAttributesIndexPath = IndexPath(row: 0, section: 1)
    
    let largerRedTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
                                   NSAttributedString.Key.foregroundColor: UIColor.red]
    let largerRedTextHighlightAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
                                            NSAttributedString.Key.foregroundColor: UIColor.blue]
    let largerRedTextSelectAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
                                         NSAttributedString.Key.foregroundColor: UIColor.orange]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        segmentedControl.segmentStyle = .textOnly
        segmentedControl.insertSegment(withTitle: "Segment 1", image: #imageLiteral(resourceName: "segment-1"), at: 0)
        segmentedControl.insertSegment(withTitle: "S 2", image: #imageLiteral(resourceName: "segment-2"), at: 1)
        segmentedControl.insertSegment(withTitle: "Segment 3.0001", image: #imageLiteral(resourceName: "segment-3"), at: 2)
        segmentedControl.insertSegment(withTitle: "Seg 4", image: #imageLiteral(resourceName: "segment-4"), at: 3)
        segmentedControl.insertSegment(withTitle: "Segment 5", image: #imageLiteral(resourceName: "segment-5"), at: 4)
        segmentedControl.insertSegment(withTitle: "Segment 6", image: #imageLiteral(resourceName: "segment-6"), at: 5)
        segmentedControl.underlineHeight = 3.0
        
        segmentedControl.underlineSelected = true
        segmentedControl.selectedSegmentIndex = 0
        //fixedWidthSwitch.isOn = false
        segmentedControl.fixedSegmentWidth = fixedWidthSwitch.isOn
        
        segmentedControl.addTarget(self, action: #selector(TableViewController.segmentSelected(sender:)), for: .valueChanged)
    }
    
    @objc func segmentSelected(sender:ScrollableSegmentedControl) {
        print("Segment at index \(sender.selectedSegmentIndex)  selected")
    }

    @IBAction func addSegment(_ sender: Any) {
        let index = segmentedControl.numberOfSegments
        segmentedControl.insertSegment(withTitle: "Segment \(index + 1)", image: #imageLiteral(resourceName: "segment-6"), at: index)
    }
    
    @IBAction func removeSegment(_ sender: Any) {
        //segmentedControl.removeSegment(at: 0)
        if segmentedControl.numberOfSegments > 1 {
            segmentedControl.removeSegment(at: segmentedControl.numberOfSegments - 1)
        }
    }
    
    @IBAction func underlineHeightChanged(_ sender: UISlider) {
        segmentedControl.underlineHeight = CGFloat(sender.value)
    }
    @IBAction func toggleFixedWidth(_ sender: UISwitch) {
        segmentedControl.fixedSegmentWidth = sender.isOn
        segmentedControl.setNeedsLayout()
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
        } else if indexPath.section == 1  {
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
                segmentedControl.setTitleTextAttributes(nil, for: .highlighted)
                segmentedControl.setTitleTextAttributes(nil, for: .selected)
            case 1:
                segmentedControl.setTitleTextAttributes(largerRedTextAttributes, for: .normal)
                segmentedControl.setTitleTextAttributes(largerRedTextHighlightAttributes, for: .highlighted)
                segmentedControl.setTitleTextAttributes(largerRedTextSelectAttributes, for: .selected)
            default: break
                
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
