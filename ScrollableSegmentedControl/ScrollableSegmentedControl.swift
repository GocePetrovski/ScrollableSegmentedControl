//
//  ScrollableSegmentedControl.swift
//  ScrollableSegmentedControl
//
//  Created by Goce Petrovski on 10/11/16.
//  Copyright © 2016 Pomarium. All rights reserved.
//

import UIKit

public enum ScrollableSegmentedControlSegmentStyle {
    case textOnly, imageOnly, imageOnTop, imageOnLeft
}

/**
A ScrollableSegmentedControl object is horizontaly scrollable control made of multiple segments, each segment functioning as discrete button.
 */
@IBDesignable
public class ScrollableSegmentedControl: UIControl {
    private let flowLayout = UICollectionViewFlowLayout()
    private var collectionView:UICollectionView?
    private var collectionViewController:CollectionViewController?
    private var segmentsData = [SegmentData]()
    private var longestTextWidth:CGFloat = 10
    
    public var segmentStyle:ScrollableSegmentedControlSegmentStyle = .textOnly {
        didSet {
            if oldValue != segmentStyle {
                switch segmentStyle {
                case .textOnly:
                    collectionView?.register(TextOnlySegmentCollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewController.textOnlyCellIdentifier)
                case .imageOnly:
                    collectionView?.register(ImageOnlySegmentCollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewController.imageOnlyCellIdentifier)
                default:
                    collectionView?.register(ImageAndTextSegmentCollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewController.imagAndTextCellIdentifier)
                }
                
                setNeedsLayout()
                flowLayout.invalidateLayout()
                collectionView?.reloadData()
            }
        }
    }
    
    override public var tintColor: UIColor! {
        didSet {
            collectionView?.tintColor = tintColor
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    // MARK: - Managing Segments
    
    /**
     Inserts a segment at a specific position in the receiver and gives it a title as content.
     */
    public func insertSegment(withTitle title: String, at index: Int) {
        let segment = SegmentData()
        segment.title = title
        segmentsData.insert(segment, at: index)
        calculateLongestTextWidth(text: title)
    }
    
    /**
     Inserts a segment at a specified position in the receiver and gives it an image as content.
     */
    public func insertSegment(with image: UIImage, at index: Int) {
        let segment = SegmentData()
        segment.image = image.withRenderingMode(.alwaysTemplate)
        segmentsData.insert(segment, at: index)
    }
    
    
    /**
     Inserts a segment at a specific position in the receiver and gives it a title as content and/or image as content.
     */
    public func insertSegment(withTitle title: String?, image: UIImage?, at index: Int) {
        let segment = SegmentData()
        segment.title = title
        segment.image = image?.withRenderingMode(.alwaysTemplate)
        segmentsData.insert(segment, at: index)
        
        if let str = title {
            calculateLongestTextWidth(text: str)
        }
    }
    
    /**
     Returns the number of segments the receiver has.
     */
    public var numberOfSegments: Int { return segmentsData.count }
    
    /**
     The index number identifying the selected segment (that is, the last segment touched).
     
     Set this property to -1 to turn off the current selection.
     */
    public var selectedSegmentIndex: Int = -1 {
        didSet{
            if selectedSegmentIndex < -1 {
                selectedSegmentIndex = -1
            } else if selectedSegmentIndex > segmentsData.count - 1 {
                selectedSegmentIndex = segmentsData.count - 1
            }
            
            if selectedSegmentIndex >= 0 {
                let indexPath = IndexPath(item: selectedSegmentIndex, section: 0)
                collectionView?.selectItem(at: indexPath, animated: true, scrollPosition: .left)
            } else {
                if let indexPath = collectionView?.indexPathsForSelectedItems?.first {
                    collectionView?.deselectItem(at: indexPath, animated: true)
                }
            }
            
            if oldValue != selectedSegmentIndex {
                self.sendActions(for: .valueChanged)
            }
        }
    }
    
    /**
     Configure if the selected segment should have underline. Default value is false.
    */
    @IBInspectable
    public var underlineSelected:Bool = false
    
    // MARK: - Layout management
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        collectionView?.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        
        configureSegmentSize()
        
        flowLayout.invalidateLayout()
        
        let tempTabIndex:Int
        if let indexPath = collectionView?.indexPathsForSelectedItems?.first {
            tempTabIndex = indexPath.item
        } else {
            tempTabIndex = -1
        }
        
        collectionView?.reloadData()
        
        self.selectedSegmentIndex = tempTabIndex
    }
    
    // MARK: - Private
    
    private func configure() {
        clipsToBounds = true
        
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        
        collectionView = UICollectionView(frame: frame, collectionViewLayout: flowLayout)
        collectionView!.tintColor = tintColor
        collectionView!.register(TextOnlySegmentCollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewController.textOnlyCellIdentifier)
        collectionViewController = CollectionViewController(segmentedControl: self)
        collectionView!.dataSource = collectionViewController
        collectionView!.delegate = collectionViewController
        collectionView!.backgroundColor = UIColor.clear
        collectionView!.showsHorizontalScrollIndicator = false
        addSubview(collectionView!)
    }
    
    private func configureSegmentSize() {
        let width:CGFloat
        
        switch segmentStyle {
        case .imageOnLeft:
            width = longestTextWidth + BaseSegmentCollectionViewCell.imageSize + BaseSegmentCollectionViewCell.imageToTextMargin * 2
        default:
            if collectionView!.frame.size.width > longestTextWidth * CGFloat(segmentsData.count) {
                width = collectionView!.frame.size.width / CGFloat(segmentsData.count)
            } else {
                width = longestTextWidth
            }
        }
        
        
        let itemSize = CGSize(width: width, height: frame.size.height)
        flowLayout.itemSize = itemSize
    }
    
    private func calculateLongestTextWidth(text:String) {
        let fontAttributes = [NSFontAttributeName: BaseSegmentCollectionViewCell.defaultFont]
        let size = (text as NSString).size(attributes: fontAttributes)
        let newLongestTextWidth = size.width + BaseSegmentCollectionViewCell.textPadding * 2
        if newLongestTextWidth > longestTextWidth {
            longestTextWidth = newLongestTextWidth
            configureSegmentSize()
        }
    }
  
    /*
     Private internal classes to be used only by this class.
     */
    
    // MARK: - SegmentData
    
    private class SegmentData {
        var title:String?
        var image:UIImage?
    }
    
    // MARK : - CollectionViewController
    
    /**
     A CollectionViewController is private inner class with main purpose to hide UICollectionView protocol conformances.
     */
    private class CollectionViewController : NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
        static let textOnlyCellIdentifier = "textOnlyCellIdentifier"
        static let imageOnlyCellIdentifier = "imageOnlyCellIdentifier"
        static let imagAndTextCellIdentifier = "imagAndTextCellIdentifier"
        
        private weak var segmentedControl: ScrollableSegmentedControl!
        
        init(segmentedControl:ScrollableSegmentedControl) {
            self.segmentedControl = segmentedControl
        }
        
        // UICollectionViewDataSource
        
        fileprivate func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
        }
        
        
        fileprivate func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return segmentedControl.numberOfSegments
        }
        
        fileprivate func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let segmentCell:BaseSegmentCollectionViewCell
            let data = segmentedControl.segmentsData[indexPath.item]
            
            switch segmentedControl.segmentStyle {
            case .textOnly:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewController.textOnlyCellIdentifier, for: indexPath) as! TextOnlySegmentCollectionViewCell
                cell.titleLabel.text = data.title
                segmentCell = cell
            case .imageOnly:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewController.imageOnlyCellIdentifier, for: indexPath) as! ImageOnlySegmentCollectionViewCell
                cell.imageView.image = data.image
                segmentCell = cell
            default:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewController.imagAndTextCellIdentifier, for: indexPath) as! ImageAndTextSegmentCollectionViewCell
                cell.titleLabel.text = data.title
                cell.imageView.image = data.image
                
                cell.containerView.axis = (segmentedControl.segmentStyle == .imageOnTop) ? .vertical : .horizontal
                
                segmentCell = cell
            }
            
            segmentCell.showUnderline = segmentedControl.underlineSelected
            
            return segmentCell
        }
        
        // MARK UICollectionViewDelegate
        
        fileprivate func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            segmentedControl.selectedSegmentIndex = indexPath.item
        }
    }

    
    // MARK: - SegmentCollectionViewCell
    
    private class BaseSegmentCollectionViewCell: UICollectionViewCell {
        static let textPadding:CGFloat = 8.0
        static let imageToTextMargin:CGFloat = 14.0
        static let imageSize:CGFloat = 14.0
        static let defaultFont = UIFont.systemFont(ofSize: 14)
        static let defaultTextColor = UIColor.darkGray
        
        var underlineView:UIView?
        
        var showUnderline:Bool = false {
            didSet {
                if oldValue != showUnderline {
                    if oldValue == false && underlineView != nil {
                        underlineView?.removeFromSuperview()
                    } else {
                        underlineView = UIView()
                        underlineView?.backgroundColor = tintColor
                        underlineView?.isHidden = true
                        contentView.insertSubview(underlineView!, at: contentView.subviews.count)
                    }
                    
                    configureConstraints()
                }
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            configure()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            configure()
        }
        
        func configure() {
            contentView.backgroundColor = UIColor.white
            configureConstraints()
        }
        
        private func configureConstraints() {
            if let underline = underlineView {
                underline.translatesAutoresizingMaskIntoConstraints = false
                underline.heightAnchor.constraint(equalToConstant: 3.0).isActive = true
                underline.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
                underline.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
                underline.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            }
        }
        
        override var isHighlighted: Bool {
            didSet {
                underlineView?.isHidden = !isHighlighted
            }
        }
        
        override var isSelected: Bool {
            didSet {
                underlineView?.isHidden = !isSelected
            }
        }
    }
    
    private class TextOnlySegmentCollectionViewCell: BaseSegmentCollectionViewCell {
        let titleLabel = UILabel()
        
        override var isHighlighted: Bool {
            didSet {
                titleLabel.textColor = (isHighlighted == true) ? UIColor.black : UIColor.darkGray
            }
        }
        
        override var isSelected: Bool {
            didSet {
                titleLabel.textColor = (isSelected == true) ? UIColor.black : UIColor.darkGray
                //titleLabel.font = (isSelected == true) ? UIFont.boldSystemFont(ofSize: 14) : UIFont.systemFont(ofSize: 14)
            }
        }
        
        override func configure(){
            super.configure()
            
            contentView.addSubview(titleLabel)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.textColor = BaseSegmentCollectionViewCell.defaultTextColor
            titleLabel.font = BaseSegmentCollectionViewCell.defaultFont
            
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: BaseSegmentCollectionViewCell.textPadding).isActive = true
            contentView.trailingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: BaseSegmentCollectionViewCell.textPadding).isActive = true
        }
    }
    
    private class ImageOnlySegmentCollectionViewCell: BaseSegmentCollectionViewCell {
        let imageView = UIImageView()
        
        override func configure(){
            super.configure()
            
            contentView.addSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.tintColor = BaseSegmentCollectionViewCell.defaultTextColor
            
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
            imageView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: BaseSegmentCollectionViewCell.textPadding).isActive = true
            contentView.trailingAnchor.constraint(greaterThanOrEqualTo: imageView.trailingAnchor, constant: BaseSegmentCollectionViewCell.textPadding).isActive = true
        }
    }
    
    private class ImageAndTextSegmentCollectionViewCell: BaseSegmentCollectionViewCell {
        let titleLabel = UILabel()
        let imageView = UIImageView()
        var containerView:UIStackView! = nil
        
        override func configure(){
            super.configure()
            containerView = UIStackView(arrangedSubviews: [imageView, titleLabel])
            contentView.addSubview(containerView)
            titleLabel.textColor = BaseSegmentCollectionViewCell.defaultTextColor
            titleLabel.font = BaseSegmentCollectionViewCell.defaultFont
            imageView.tintColor = BaseSegmentCollectionViewCell.defaultTextColor
            
            containerView.axis = .vertical
            containerView.alignment = .center
            containerView.distribution = .equalCentering
            containerView.spacing = BaseSegmentCollectionViewCell.textPadding
            
            containerView.addSubview(titleLabel)
            containerView.addSubview(imageView)
            
            
            containerView.translatesAutoresizingMaskIntoConstraints = false
            
            containerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
            containerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        }
    }
}
