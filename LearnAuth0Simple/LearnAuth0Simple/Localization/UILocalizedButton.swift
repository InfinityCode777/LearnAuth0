//
//  UILocalizedButton.swift
//  F8SDK
//
//  Created by Jing Wang on 1/24/19.
//  Copyright © 2019 figur8. All rights reserved.
//

import UIKit

//@IBDesignable
final public class UILocalizedButton: UIButton {
    
    private var bundle: Bundle = .main
    
    
    @IBInspectable
    public var tableName: String? {
        didSet {
            guard let tableName = tableName else { return }
            guard let _ = tableBundle else { return }
            guard let locTextValue = locTextKey?.localized(bundle: bundle, tableName: tableName) else { return }
            setTitle(locTextValue, for: .normal)
        }
    }
    
    @IBInspectable
    public var locTextKey: String? {
        didSet {
            guard let tableName = tableName else { return }
            guard let _ = tableBundle else { return }
            guard let locTextValue = locTextKey?.localized(bundle: bundle, tableName: tableName) else { return }
            setTitle(locTextValue, for: .normal)
        }
    }
    
    
    @IBInspectable
    public var tableBundle: String? {
        didSet {
            guard let tableName = tableName else { return }
            guard let tableBundle = tableBundle else { return }
            if tableBundle.lowercased().contains("main") {
                bundle = Bundle.main
            } else if tableBundle.lowercased().contains("sdk") {
                bundle = Utils.sharedInstance.getF8SdkResourceBundle()
            }
            guard let locTextValue = locTextKey?.localized(bundle: bundle, tableName: tableName) else { return }
            setTitle(locTextValue, for: .normal)
        }
    }
    
    @IBInspectable public var borderWidth: CGFloat  = 0.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }

    @IBInspectable public var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }

    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
}
