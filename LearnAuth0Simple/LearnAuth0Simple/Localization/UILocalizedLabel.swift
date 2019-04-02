//
//  UILocalizedLabel.swift
//  F8SDK
//
//  Created by Jing Wang on 1/23/19.
//  Copyright © 2019 figur8. All rights reserved.
//

//enum F8BundleType: String {
//    case main
//    case sdk
//}

import UIKit

//@IBDesignable
final public class UILocalizedLabel: UILabel {
    
    private var bundle: Bundle = .main
    
    
    @IBInspectable
    public var tableName: String? {
        didSet {
            guard let tableName = tableName else { return }
            guard let _ = tableBundle else { return }
            guard let locTextValue = locTextKey?.localized(bundle: bundle, tableName: tableName) else { return }
            text = locTextValue
        }
    }
    
    @IBInspectable
    public var locTextKey: String? {
        didSet {
            guard let tableName = tableName else { return }
            guard let _ = tableBundle else { return }
            guard let locTextValue = locTextKey?.localized(bundle: bundle, tableName: tableName) else { return }
            text = locTextValue
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
            text = locTextValue
        }
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
