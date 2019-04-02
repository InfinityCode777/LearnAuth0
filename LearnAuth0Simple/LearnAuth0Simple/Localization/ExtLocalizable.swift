//
//  ExtLocalizable.swift
//  F8SDK
//
//  Created by Jing Wang on 1/23/19.
//  Copyright © 2019 figur8. All rights reserved.
//

import Foundation


public protocol F8Localizable {
    var tableName: String { get }
    var tableBundle: Bundle { get }
    var localized: String { get }
}


// In order that we can use [YOUR_STRING].localized() method
public extension String {
    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
        let localizedString: String = NSLocalizedString(self, tableName: tableName, bundle: bundle, value: "**\(self)**", comment: "")
        return localizedString
    }
}

// Extend Localizable only if it is enum with string type
public extension F8Localizable where Self: RawRepresentable, Self.RawValue == String {
    var localized: String {
        return rawValue.localized(bundle: tableBundle, tableName: tableName)
    }
}
