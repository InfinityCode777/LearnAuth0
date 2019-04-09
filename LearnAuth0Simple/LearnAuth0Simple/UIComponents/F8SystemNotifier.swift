//
//  F8SystemNotifier.swift
//  F8SDK
//
//  Created by Jing Wang on 3/18/19.
//  Copyright © 2019 figur8. All rights reserved.
//
import UIKit
import Anchorage

public class F8SystemNotifier: UIView {
    
    //    private let titleText = "Title of notifier"
    //    private let bodyText = "Body of notifier"
    public var captionImage: UIImage? = UIImage() {
        didSet {
            captionImageView.image = captionImage
        }
    }
    private var isUIDebug = false
    
    private var resourceBundle: Bundle = Bundle(for: F8SystemNotifier.self)
    
    public var blurButtonTappedHandler: ((_ sender: Any) -> ())?
    public var withBlurBackground = true
    public var titleText: String = "Title of notifier"{
        didSet {
            titleLabel.text = titleText
        }
    }
    
    public var bodyText: String = "Body of notifier" {
        didSet {
            bodyLabel.text = bodyText
        }
    }
    
    private var popupBounds: CGRect = {
        //        let heightWidthRatio: CGFloat = 128.0/375.0
        //        let height: CGFloat = ((UIScreen.main.bounds.width - 16.0)*heightWidthRatio).rounded()
        let height: CGFloat = 128
        let width: CGFloat = UIScreen.main.bounds.width - 16.0 // Safe area margin on both sides
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        return rect
    }()
    
    
    /// Container view of popup window
    private lazy var popupView: UIView = {
        let view = UIView(frame: popupBounds)
        view.layer.cornerRadius = 14
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.clear.cgColor
        view.clipsToBounds = true
        /// Change color in during UI DEBUG
        view.backgroundColor = isUIDebug ? UIColor.green : UIColor.white
        view.alpha = 0.8
        return view
    }()
    
    
    /// Background blur view/button
    private lazy var blurButton: UIButton = {
        let button = UIButton(frame: UIScreen.main.bounds)
        button.addTarget(self, action: #selector(onBlurButtonTapped(_:)), for: .touchUpInside)
        button.addBlurEffect()
        /// Change color in during UI DEBUG
        button.backgroundColor = isUIDebug ? UIColor.yellow : UIColor.clear
        return button
    }()
    
    /// Components for popup window - Caption image
    private lazy var captionImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 12, y: 12, width: 20, height: 20))
        //        imageView.image = UIImage(named: backgroundImage, in: resourceBundle, compatibleWith: nil)
        imageView.image = captionImage
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        /// Change color in during UI DEBUG
        imageView.backgroundColor = isUIDebug ? UIColor.cyan : UIColor.clear
        return imageView
    }()
    
    
    /// Components for popup window - Title
    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 38, y: 13, width: 178, height: 20))
        label.text = titleText
        label.textColor = F8ColorScheme.DEFAULT_BACKGROUND_NIGHT
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.textAlignment = .center
        /// Change color in during UI DEBUG
        label.backgroundColor = isUIDebug ? UIColor.blue : UIColor.clear
        return label
    }()
    
    
    /// Components for popup window - Body
    private lazy var bodyLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 20, y: 46, width: 335, height: 60))
        label.textColor = F8ColorScheme.DEFAULT_BACKGROUND_NIGHT
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        label.text = bodyText
        label.textAlignment = .left
        /// Change color in during UI DEBUG
        label.backgroundColor = isUIDebug ? UIColor.magenta : UIColor.clear
        return label
    }()
    
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public convenience init(titleText: String, bodyText: String, captionImage: UIImage?, withBlurBackground: Bool, resourceBundle: Bundle) {
        //        let frame = CGRect(x: 0, y: 232, width: 375, height: 128)
        
        self.init(frame: UIScreen.main.bounds)
        self.titleLabel.text = titleText
        self.bodyLabel.text = bodyText
        self.captionImageView.image = captionImage
        self.resourceBundle = resourceBundle
        self.withBlurBackground = withBlurBackground
        self.frame = withBlurBackground ? UIScreen.main.bounds : popupBounds
        
    }
    
    
    /// Set constraints for subviews
    override public func didMoveToSuperview() {
        
        self.backgroundColor = isUIDebug ? UIColor.darkGray : UIColor.clear
        
        /// The width and height of bounds for popup window
        let popupBoundsWidth = popupBounds.width
        let popupBoundsHeight = popupBounds.height
        
        
        // Add background blur view
        if withBlurBackground {
            self.addSubview(blurButton)
            blurButton.topAnchor == self.topAnchor
            blurButton.bottomAnchor == self.bottomAnchor
            blurButton.leadingAnchor == self.leadingAnchor
            blurButton.trailingAnchor == self.trailingAnchor
        }
        
        // Add container view of popup window
        self.addSubview(popupView)
        //        popupView.sizeAnchors == CGSize(width: popupBoundsWidth, height: popupBoundsHeight)
        popupView.widthAnchor == popupBoundsWidth
        popupView.heightAnchor >= popupBoundsHeight
        popupView.heightAnchor <= 200
        popupView.centerAnchors == self.centerAnchors
        
        
        popupView.addSubview(captionImageView)
        popupView.addSubview(titleLabel)
        popupView.addSubview(bodyLabel)
        
        
        captionImageView.sizeAnchors == CGSize(width: 20, height: 20)
        captionImageView.leadingAnchor == popupView.leadingAnchor + 12
        captionImageView.topAnchor == popupView.topAnchor + 12
        
        titleLabel.heightAnchor == 20
        titleLabel.leadingAnchor == captionImageView.trailingAnchor + 8
        titleLabel.topAnchor == popupView.topAnchor + 12
        titleLabel.widthAnchor <= popupView.widthAnchor - 16
        
        bodyLabel.heightAnchor <= popupView.heightAnchor - 44
        //        bodyLabel.widthAnchor <= popupView.widthAnchor - 16
        bodyLabel.trailingAnchor == popupView.trailingAnchor - 12
        bodyLabel.leadingAnchor == popupView.leadingAnchor + 12
        bodyLabel.topAnchor == captionImageView.bottomAnchor + 8
    }
    
    @objc private func onBlurButtonTapped(_ sender: Any) {
        blurButtonTappedHandler?(sender)
    }
}
