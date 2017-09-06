//
//  ScrollableSegmentedControl.swift
//  ScrollableSegmentedControl
//
//  Created by Goce Petrovski on 10/11/16.
//  Copyright © 2017 Pomarium. All rights reserved.
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
    fileprivate let flowLayout = UICollectionViewFlowLayout()
    fileprivate var collectionView:UICollectionView?
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
                case .imageOnTop:
                    collectionView?.register(ImageOnTopSegmentCollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewController.imageOnTopCellIdentifier)
                case .imageOnLeft:
                    collectionView?.register(ImageOnLeftSegmentCollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewController.imageOnLeftCellIdentifier)
                }
                
                let indexPath = collectionView?.indexPathsForSelectedItems?.last
                
                setNeedsLayout()
                flowLayout.invalidateLayout()
                reloadSegments()
                
                if indexPath != nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
                        self.collectionView?.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.left)
                    })
                }
                
            }
        }
    }
    
    override public var tintColor: UIColor! {
        didSet {
            collectionView?.tintColor = tintColor
            reloadSegments()
        }
    }
    
    fileprivate var _segmentContentColor:UIColor?
    @objc public dynamic var segmentContentColor:UIColor? {
        get { return _segmentContentColor }
        set {
            _segmentContentColor = newValue
            reloadSegments()
        }
    }
    
    fileprivate var _selectedSegmentContentColor:UIColor?
    @objc public dynamic var selectedSegmentContentColor:UIColor? {
        get { return _selectedSegmentContentColor }
        set {
            _selectedSegmentContentColor = newValue
            reloadSegments()
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
    
    fileprivate var normalAttributes:[NSAttributedStringKey : Any]?
    fileprivate var highlightedAttributes:[NSAttributedStringKey : Any]?
    fileprivate var selectedAttributes:[NSAttributedStringKey : Any]?
    fileprivate var _titleAttributes:[UInt: [NSAttributedStringKey : Any]] = [UInt: [NSAttributedStringKey : Any]]()
    public func setTitleTextAttributes(_ attributes: [NSAttributedStringKey : Any]?, for state: UIControlState) {
        _titleAttributes[state.rawValue] = attributes
        
        normalAttributes = _titleAttributes[UIControlState.normal.rawValue]
        highlightedAttributes = _titleAttributes[UIControlState.highlighted.rawValue]
        selectedAttributes = _titleAttributes[UIControlState.selected.rawValue]
        
        for segment in segmentsData {
            configureAttributedTitlesForSegment(segment)
            
            if let title = segment.title {
                calculateLongestTextWidth(text: title)
            }
        }
        
        flowLayout.invalidateLayout()
        reloadSegments()
    }
    
    private func configureAttributedTitlesForSegment(_ segment:SegmentData) {
        segment.normalAttributedTitle = nil
        segment.highlightedAttributedTitle = nil
        segment.selectedAttributedTitle = nil
        
        if let title = segment.title {
            if normalAttributes != nil {
                segment.normalAttributedTitle = NSAttributedString(string: title, attributes: normalAttributes!)
            }
            
            if highlightedAttributes != nil {
                segment.highlightedAttributedTitle = NSAttributedString(string: title, attributes: highlightedAttributes!)
            } else {
                if selectedAttributes != nil {
                    segment.highlightedAttributedTitle = NSAttributedString(string: title, attributes: selectedAttributes!)
                } else {
                    if normalAttributes != nil {
                        segment.highlightedAttributedTitle = NSAttributedString(string: title, attributes: normalAttributes!)
                    }
                }
            }
            
            if selectedAttributes != nil {
                segment.selectedAttributedTitle = NSAttributedString(string: title, attributes: selectedAttributes!)
            } else {
                if highlightedAttributes != nil {
                    segment.selectedAttributedTitle = NSAttributedString(string: title, attributes: highlightedAttributes!)
                } else {
                    if normalAttributes != nil {
                        segment.selectedAttributedTitle = NSAttributedString(string: title, attributes: normalAttributes!)
                    }
                }
            }
        }
    }
    
    public func titleTextAttributes(for state: UIControlState) -> [NSAttributedStringKey : Any]? {
        return _titleAttributes[state.rawValue]
    }
    
    // MARK: - Managing Segments
    
    /**
     Inserts a segment at a specific position in the receiver and gives it a title as content.
     */
    public func insertSegment(withTitle title: String, at index: Int) {
        let segment = SegmentData()
        segment.title = title
        configureAttributedTitlesForSegment(segment)
        segmentsData.insert(segment, at: index)
        calculateLongestTextWidth(text: title)
        reloadSegments()
    }
    
    /**
     Inserts a segment at a specified position in the receiver and gives it an image as content.
     */
    public func insertSegment(with image: UIImage, at index: Int) {
        let segment = SegmentData()
        segment.image = image.withRenderingMode(.alwaysTemplate)
        segmentsData.insert(segment, at: index)
        reloadSegments()
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
        reloadSegments()
    }
    
    /**
     Removes segment at a specific position from the receiver.
     */
    public func removeSegment(at segment: Int){
        segmentsData.remove(at: segment)
        reloadSegments()
    }
    
    /**
     Returns the number of segments the receiver has.
     */
    public var numberOfSegments: Int { return segmentsData.count }
    
    /**
     Returns the title of the specified segment.
     */
    func titleForSegment(at segment: Int) -> String? {
        if segmentsData.count == 0 {
            return nil
        }
        
        return safeSegmentData(forIndex: segment).title
    }
    
    
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
        collectionView?.contentOffset = CGPoint(x: 0, y: 0)
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        configureSegmentSize()
        
        flowLayout.invalidateLayout()
        
        reloadSegments()
    }
    
    // MARK: - Private
    
    fileprivate func configure() {
        clipsToBounds = true
        
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        
        collectionView = UICollectionView(frame: frame, collectionViewLayout: flowLayout)
        collectionView!.tag = 1
        collectionView!.tintColor = tintColor
        collectionView!.register(TextOnlySegmentCollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewController.textOnlyCellIdentifier)
        collectionViewController = CollectionViewController(segmentedControl: self)
        collectionView!.dataSource = collectionViewController
        collectionView!.delegate = collectionViewController
        collectionView!.backgroundColor = UIColor.clear
        collectionView!.showsHorizontalScrollIndicator = false
        addSubview(collectionView!)
    }
    
    fileprivate func configureSegmentSize() {
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
    
    fileprivate func calculateLongestTextWidth(text:String) {
        let fontAttributes:[NSAttributedStringKey:Any]
        if normalAttributes != nil {
            fontAttributes = normalAttributes!
        } else  if highlightedAttributes != nil {
            fontAttributes = highlightedAttributes!
        } else if selectedAttributes != nil {
            fontAttributes = selectedAttributes!
        } else {
            fontAttributes =  [NSAttributedStringKey.font: BaseSegmentCollectionViewCell.defaultFont]
        }
        
        let size = (text as NSString).size(withAttributes: fontAttributes)
        let newLongestTextWidth = 2.0 + size.width + BaseSegmentCollectionViewCell.textPadding * 2
        if newLongestTextWidth > longestTextWidth {
            longestTextWidth = newLongestTextWidth
            configureSegmentSize()
        }
    }
    
    private func safeSegmentData(forIndex index:Int) -> SegmentData {
        let segmentData:SegmentData
        
        if index <= 0 {
            segmentData = segmentsData[0]
        } else if index >= segmentsData.count {
            segmentData = segmentsData[segmentsData.count - 1]
        } else {
            segmentData = segmentsData[index]
        }
        
        return segmentData
    }
    
    fileprivate func reloadSegments() {
        if let collectionView_ = collectionView {
            collectionView_.reloadData()
            if selectedSegmentIndex >= 0 {
                let indexPath = IndexPath(item: selectedSegmentIndex, section: 0)
                collectionView_.selectItem(at: indexPath, animated: true, scrollPosition: .left)
            }
        }
    }
    
    /*
     Private internal classes to be used only by this class.
     */
    
    // MARK: - SegmentData
    
    final private class SegmentData {
        var title:String?
        var normalAttributedTitle:NSAttributedString?
        var highlightedAttributedTitle:NSAttributedString?
        var selectedAttributedTitle:NSAttributedString?
        var image:UIImage?
    }
    
    // MARK : - CollectionViewController
    
    /**
     A CollectionViewController is private inner class with main purpose to hide UICollectionView protocol conformances.
     */
    final private class CollectionViewController : NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
        static let textOnlyCellIdentifier = "textOnlyCellIdentifier"
        static let imageOnlyCellIdentifier = "imageOnlyCellIdentifier"
        static let imageOnTopCellIdentifier = "imageOnTopCellIdentifier"
        static let imageOnLeftCellIdentifier = "imageOnLeftCellIdentifier"
        
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
            case .imageOnTop:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewController.imageOnTopCellIdentifier, for: indexPath) as! ImageOnTopSegmentCollectionViewCell
                cell.titleLabel.text = data.title
                cell.imageView.image = data.image
                
                segmentCell = cell
            case .imageOnLeft:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewController.imageOnLeftCellIdentifier, for: indexPath) as! ImageOnLeftSegmentCollectionViewCell
                cell.titleLabel.text = data.title
                cell.imageView.image = data.image
                
                segmentCell = cell
            }
            
            segmentCell.showUnderline = segmentedControl.underlineSelected
            if segmentedControl.underlineSelected {
                segmentCell.tintColor = segmentedControl.tintColor
            }
            
            
            segmentCell.contentColor = segmentedControl.segmentContentColor
            segmentCell.selectedContentColor = segmentedControl.selectedSegmentContentColor
            
            segmentCell.normalAttributedTitle = data.normalAttributedTitle
            segmentCell.highlightedAttributedTitle = data.highlightedAttributedTitle
            segmentCell.selectedAttributedTitle = data.selectedAttributedTitle
            
            return segmentCell
        }
        
        // MARK UICollectionViewDelegate
        
        fileprivate func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            segmentedControl.selectedSegmentIndex = indexPath.item
        }
        
        fileprivate func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            var label:UILabel?
            if let _cell = cell as? TextOnlySegmentCollectionViewCell {
                label = _cell.titleLabel
            } else if let _cell = cell as? ImageOnTopSegmentCollectionViewCell {
                label = _cell.titleLabel
            } else if let _cell = cell as? ImageOnLeftSegmentCollectionViewCell {
                label = _cell.titleLabel
            } else {
                label = nil
            }
            
            if let titleLabel = label {
                let data = segmentedControl.segmentsData[indexPath.item]
                
                if cell.isHighlighted && data.highlightedAttributedTitle != nil {
                    titleLabel.attributedText = data.highlightedAttributedTitle!
                } else if cell.isSelected && data.selectedAttributedTitle != nil {
                    titleLabel.attributedText = data.selectedAttributedTitle!
                } else {
                    if data.normalAttributedTitle != nil {
                        titleLabel.attributedText = data.normalAttributedTitle!
                    }
                }
            }
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
        public var contentColor:UIColor?
        public var selectedContentColor:UIColor?
        
        var normalAttributedTitle:NSAttributedString?
        var highlightedAttributedTitle:NSAttributedString?
        var selectedAttributedTitle:NSAttributedString?
        
        var showUnderline:Bool = false {
            didSet {
                if oldValue != showUnderline {
                    if oldValue == false && underlineView != nil {
                        underlineView?.removeFromSuperview()
                    } else {
                        underlineView = UIView()
                        underlineView!.tag = 999
                        underlineView!.backgroundColor = tintColor
                        underlineView!.isHidden = !isSelected
                        contentView.insertSubview(underlineView!, at: contentView.subviews.count)
                    }
                    
                    configureConstraints()
                }
            }
        }
        
        override var tintColor: UIColor!{
            didSet{
                underlineView?.backgroundColor = tintColor
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
        
        override var contentColor:UIColor? {
            didSet {
                titleLabel.textColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
            }
        }
        
        override var selectedContentColor:UIColor? {
            didSet {
                titleLabel.highlightedTextColor = (selectedContentColor == nil) ? UIColor.black : selectedContentColor!
            }
        }
        
        override var isHighlighted: Bool {
            didSet {
                if let title = (isHighlighted) ? super.highlightedAttributedTitle : super.normalAttributedTitle {
                    titleLabel.attributedText = title
                } else {
                    titleLabel.isHighlighted = isHighlighted
                }
            }
        }
        
        override var isSelected: Bool {
            didSet {
                if isSelected {
                    if let title = super.selectedAttributedTitle {
                        titleLabel.attributedText = title
                    } else {
                        titleLabel.textColor = (selectedContentColor == nil) ? UIColor.black : selectedContentColor!
                    }
                } else {
                    if let title = super.normalAttributedTitle {
                        titleLabel.attributedText = title
                    } else {
                        titleLabel.textColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
                    }
                }
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
        
        override var contentColor:UIColor? {
            didSet {
                imageView.tintColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
            }
        }
        
        override var isHighlighted: Bool {
            didSet {
                if isHighlighted {
                    imageView.tintColor = (selectedContentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : selectedContentColor!
                } else {
                    imageView.tintColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
                }
            }
        }
        
        override var isSelected: Bool {
            didSet {
                if isSelected {
                    imageView.tintColor = (selectedContentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : selectedContentColor!
                } else {
                    imageView.tintColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
                }
            }
        }
        
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
    
    private class ImageOnTopSegmentCollectionViewCell: BaseSegmentCollectionViewCell {
        let titleLabel = UILabel()
        let imageView = UIImageView()
        
        override var contentColor:UIColor? {
            didSet {
                titleLabel.textColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
                imageView.tintColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
            }
        }
        
        override var selectedContentColor:UIColor? {
            didSet {
                titleLabel.highlightedTextColor = (selectedContentColor == nil) ? UIColor.black : selectedContentColor!
            }
        }
        
        override var isHighlighted: Bool {
            didSet {
                if let title = (isHighlighted) ? super.highlightedAttributedTitle : super.normalAttributedTitle {
                    titleLabel.attributedText = title
                } else {
                    titleLabel.isHighlighted = isHighlighted
                }
                
                if isHighlighted {
                    imageView.tintColor = (selectedContentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : selectedContentColor!
                } else {
                    imageView.tintColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
                }
            }
        }
        
        override var isSelected: Bool {
            didSet {
                if isSelected {
                    if let title = super.selectedAttributedTitle {
                        titleLabel.attributedText = title
                    } else {
                        titleLabel.textColor = (selectedContentColor == nil) ? UIColor.black : selectedContentColor!
                    }
                    imageView.tintColor = (selectedContentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : selectedContentColor!
                } else {
                    if let title = super.normalAttributedTitle {
                        titleLabel.attributedText = title
                    } else {
                        titleLabel.textColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
                    }
                    imageView.tintColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
                }
            }
        }
        
        override func configure(){
            super.configure()
            titleLabel.font = BaseSegmentCollectionViewCell.defaultFont
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            contentView.addSubview(titleLabel)
            contentView.addSubview(imageView)
            
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
            titleLabel.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -BaseSegmentCollectionViewCell.textPadding).isActive = true
            imageView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -BaseSegmentCollectionViewCell.textPadding).isActive = true
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: BaseSegmentCollectionViewCell.textPadding).isActive = true
        }
    }
    
    private class ImageOnLeftSegmentCollectionViewCell: BaseSegmentCollectionViewCell {
        let titleLabel = UILabel()
        let imageView = UIImageView()
        
        override var contentColor:UIColor? {
            didSet {
                titleLabel.textColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
                imageView.tintColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
            }
        }
        
        override var selectedContentColor:UIColor? {
            didSet {
                titleLabel.highlightedTextColor = (selectedContentColor == nil) ? UIColor.black : selectedContentColor!
            }
        }
        
        override var isHighlighted: Bool {
            didSet {
                if let title = (isHighlighted) ? super.highlightedAttributedTitle : super.normalAttributedTitle {
                    titleLabel.attributedText = title
                } else {
                    titleLabel.isHighlighted = isHighlighted
                }
                
                if isHighlighted {
                    imageView.tintColor = (selectedContentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : selectedContentColor!
                } else {
                    imageView.tintColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
                }
            }
        }
        
        override var isSelected: Bool {
            didSet {
                if isSelected {
                    if let title = super.selectedAttributedTitle {
                        titleLabel.attributedText = title
                    } else {
                        titleLabel.textColor = (selectedContentColor == nil) ? UIColor.black : selectedContentColor!
                    }
                    imageView.tintColor = (selectedContentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : selectedContentColor!
                } else {
                    if let title = super.normalAttributedTitle {
                        titleLabel.attributedText = title
                    } else {
                        titleLabel.textColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
                    }
                    imageView.tintColor = (contentColor == nil) ? BaseSegmentCollectionViewCell.defaultTextColor : contentColor!
                }
            }
        }
        
        override func configure(){
            super.configure()
            titleLabel.font = BaseSegmentCollectionViewCell.defaultFont
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            
            contentView.addSubview(titleLabel)
            contentView.addSubview(imageView)
            
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            imageView.heightAnchor.constraint(equalToConstant: BaseSegmentCollectionViewCell.imageSize).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: BaseSegmentCollectionViewCell.imageSize).isActive = true
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: BaseSegmentCollectionViewCell.textPadding).isActive = true
            titleLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: BaseSegmentCollectionViewCell.textPadding).isActive = true
            contentView.trailingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: BaseSegmentCollectionViewCell.textPadding).isActive = true
        }
    }
}

