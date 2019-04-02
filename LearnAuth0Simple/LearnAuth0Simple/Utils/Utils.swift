//
//  Utils.swift
//  myBluetoothie
//
//  Created by Jing Wang on 2/1/17.
//  Copyright © 2017 Jing Wang. All rights reserved.
//

//import Foundation
import UIKit

public class Utils {
    
    public static let sharedInstance = Utils()
    
    // Used to locate shared directory for zip file storage
    //private static let appGroupIdentifier = "group.com.figur8me.f8appgroup"
    
    /** Default constructor **/
    private init(){
    }
    
    public func info(infoTitle: String, infoBody: String, ui: UIViewController?, cbOK: @escaping () -> Void) {
        
        guard let ui = ui else {
            F8Log.warn("Early return, no parent viewController to present UIAlert!")
            return
        }
        
        let dialog = UIAlertController(title: infoTitle, message: infoBody, preferredStyle: UIAlertController.Style.alert)
        let OKAction = UIAlertAction(title: F8LocaleStrings.okText.localized, style: .default){ (action) in cbOK() }
        dialog.addAction(OKAction)
        // Present the dialog
        ui.present(dialog, animated: false, completion: nil)
    }
    
    
    
    public func error(message: String, ui: UIViewController, cbOK: @escaping () -> Void) {
        let dialog = UIAlertController(title: F8LocaleStrings.errorText.localized, message: message, preferredStyle: UIAlertController.Style.alert)
        let OKAction = UIAlertAction(title: F8LocaleStrings.okText.localized, style: .default) { (action) in cbOK() }
        
        dialog.addAction(OKAction)
        // Present the dialog
        ui.present(dialog,animated: false, completion: nil)
    }
    
    public func error(_ infoTitle: String, _ infoBody:String, _ displayTime: Double, ui: UIViewController) {
        let dialog = UIAlertController(title: infoTitle, message: infoBody, preferredStyle: UIAlertController.Style.alert)
        //        let OKAction = UIAlertAction(title: "OK", style: .default)
        //        dialog.addAction(OKAction)
        // Present the dialog
        ui.present(dialog,animated: false, completion: nil)
        
        // change to desired number of seconds (in this case 5 seconds)
        let when = DispatchTime.now() + displayTime
        DispatchQueue.main.asyncAfter(deadline: when){
            // your code with delay
            dialog.dismiss(animated: true, completion: nil)
        }
    }
    
    public func info(_ infoTitle: String, _ infoBody:String, displayTime: Double? = nil, ui: UIViewController) {
        let refreshAlert = UIAlertController(title: infoTitle, message: infoBody, preferredStyle: UIAlertController.Style.alert)
        if let dt = displayTime {
            let when = DispatchTime.now() + dt
            DispatchQueue.main.asyncAfter(deadline: when){
                refreshAlert.dismiss(animated: true, completion: nil)
            }
        }
        else {
            refreshAlert.addAction(UIAlertAction(title: F8LocaleStrings.confirmText.localized, style: .default, handler: { (action: UIAlertAction!) in
                // If we confirm, do something here
            }))
        }
        ui.present(refreshAlert, animated: true, completion: nil)
    }
    
    // Helps print names of enums
    // https://stackoverflow.com/questions/24007461/how-to-enumerate-an-enum-with-string-type/28341290#28341290
    public func iterateEnum<T: Hashable>(_: T.Type) -> AnyIterator<T> {
        var i = 0
        return AnyIterator {
            let next = withUnsafeBytes(of: &i) { $0.load(as: T.self) }
            if next.hashValue != i { return nil }
            i += 1
            return next
        }
    }
    
    @available(*, deprecated, message: "Use Date extensions.")
    /// Gets the figur8 timestamp in the right format
    public func getTimestampAsString(date: Date, dateFormat: String) -> String {
        let fmt = DateFormatter()
        // KMD:  Go back to the old timestamp for now.
        fmt.dateFormat = dateFormat;
        let timeStamp = fmt.string(from: date)
        return timeStamp
    }
    
    /// Returns a random number to use when generating filenames.
    public func getRandomNumber() -> UInt32 {
        // Save data to file
        return arc4random_uniform(8999) + UInt32(1000)
    }
    
    /// Turns a device time tick into a Date
    /// Conversion factor is conversion from timeTick to seconds
    public func getTimestampFromTicks(fromTime : Date, timeTick: Int32, conversionFactor: Double) -> Date {
        let seconds = Double(timeTick) * conversionFactor
        return fromTime.addingTimeInterval(seconds)
    }
    
    /**
     Returns the short version string
     **/
    public func getShortVersionString() -> String {
        let dictionary = Bundle.main.infoDictionary!
        return dictionary["CFBundleShortVersionString"] as! String
    }
    
    /** Returns the app name
     **/
    public func getAppName() -> String {
        let dictionary = Bundle.main.infoDictionary!
        return dictionary["CFBundleDisplayName"] as! String
    }
    
    /// Returns the version of the app
    public func getVersion() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = Utils.sharedInstance.getShortVersionString()
        let build = dictionary["CFBundleVersion"] as! String
        let name = getAppName()
        return "\(name) v\(version) Build \(build)"
    }
    
    /// Gets the bundle for the
    public func getF8SdkResourceBundle() -> Bundle {
        let podBundle = Bundle(for: Utils.self)
        let bundleURL = podBundle.url(forResource: "F8SDK", withExtension: "bundle")
        return Bundle(url: bundleURL!)!
    }
    
    private var isDevBuild: Bool? = nil
    
    // Returns true if this is a dev build. Tests the short version string ends with dev
    public func isDev() -> Bool {
        if self.isDevBuild == nil {
            self.isDevBuild = Utils.sharedInstance.getAppName().hasSuffix("Dev")
        }
        return self.isDevBuild!;
    }
    
    // Returns true if this is an internal build, either alpha or dev
    public var isInternalBuild: Bool { return Utils.sharedInstance.getAppName().lowercased().hasSuffix("alpha") || Utils.sharedInstance.getAppName().lowercased().hasSuffix("x") ||  Utils.sharedInstance.getAppName().lowercased().hasSuffix("dev")}
    
    
    public static let documentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    
    /// Creates a subfolder specified by URL.  Returns nil upon error, else returns the new or existing URL
    public static func getOrCreateSubfolder(url: URL?) -> URL? {
        
        // Nothing to do
        guard let storageUrl = url else {
            return nil
        }
        
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: storageUrl.path){
            do {
                try fileManager.createDirectory(atPath: storageUrl.path, withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                F8Log.error("error creating filepath: \(error)")
                return nil
            }
        }
        return storageUrl
    }
    
    //    // Function to locate shared data location. Must use the shared data location for any data
    //    // that the share extension needs access to
    //    public static func appGroupContainerURL() -> URL? {
    //        let fileManager = FileManager.default
    //        guard let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) else {
    //            return nil
    //        }
    //        return getOrCreateSubfolder(url: groupURL.appendingPathComponent("SharedStorage"))
    //    }
    
    //    // Removes .zip files in the program's directory document. We only create these on the
    //    // fly for transfer, so they are deleted immediately afterwards
    //    public func removeTemporarySharedGroupFiles(){
    //        // Get the document directory url
    //
    //        //let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    //        let documentsUrl = Utils.appGroupContainerURL()!
    //
    //        do {
    //            // Get the directory contents urls (including subfolders urls)
    //            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
    //            print(directoryContents)
    //
    //            // if you want to filter the directory contents you can do like this:
    //            let files = directoryContents.filter{ $0.pathExtension == "zip" }
    //            //print("zip files:",files)
    //
    //            for file in files {
    //                try FileManager.default.removeItem(at: file)
    //            }
    //
    //        } catch let error as NSError {
    //            print(error.localizedDescription)
    //        }
    //    }
    
    /// Parse input string, if the last chara in string is a number then increase by one and return new string
    public func lastNumAutoChange(_ stringName: String, by increment: Int) -> String {
        
        /// Method: Divide the test name into two parts: Prefix/Suffix
        
        // Init a new string
        var newStringName = ""
        // Search for the last digit using regex, return nil if not found
        let matchResult = stringName.matchingStrings(regex: ".*?([0-9]+)$")
        
        // If there a match, extract the searching result other wise return input string
        guard let testNameSuffix = matchResult.first?.last else {
            return stringName
        }
        
        // Get the indexes of suffix in input string
        let suffixBeginIndexes = stringName.indexes(of: testNameSuffix)
        // The index of last appearance of suffix
        if let suffixBeginIndex = suffixBeginIndexes.last {
            // Get the prefix of input string based on index above
            let testNamePrefix = String(stringName.prefix(upTo: suffixBeginIndex))
            // Bump up last number and update input string
            if let testNameSuffixInt = Int(testNameSuffix) {
                newStringName = "\(testNamePrefix)\(testNameSuffixInt + increment)"
            }
        }
        return newStringName
    }
    
    
    
}


// Extension to get substring in a string using regex
extension String {
    func matchingStrings(regex: String) -> [[String]] {
        guard let regex = try? NSRegularExpression(pattern: regex, options: []) else { return [] }
        let nsString = self as NSString
        let results  = regex.matches(in: self, options: [], range: NSMakeRange(0, nsString.length))
        return results.map { result in
            (0..<result.numberOfRanges).map { result.range(at: $0).location != NSNotFound
                ? nsString.substring(with: result.range(at: $0))
                : ""
            }
        }
    }
}

//https://oleb.net/blog/2016/12/optionals-string-interpolation/
infix operator ???: NilCoalescingPrecedence
public func ???<T>(optional: T?, defaultValue: @autoclosure () -> String) -> String {
    switch optional {
    case let value?: return String(describing: value)
    case nil: return defaultValue()
    }
}

// Extension to get index of a substring in a string
extension String {
    func index(of string: String, options: CompareOptions = .literal) -> Index? {
        return range(of: string, options: options)?.lowerBound
    }
    func endIndex(of string: String, options: CompareOptions = .literal) -> Index? {
        return range(of: string, options: options)?.upperBound
    }
    func indexes(of string: String, options: CompareOptions = .literal) -> [Index] {
        var result: [Index] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range.lowerBound)
            start = range.upperBound
        }
        return result
    }
    //    func ranges(of string: String, options: CompareOptions = .literal) -> [Range<Index>] {
    //        var result: [Range<Index>] = []
    //        var start = startIndex
    //        while let range = range(of: string, options: options, range: start..<endIndex) {
    //            result.append(range)
    //            start = range.upperBound
    //        }
    //        return result
    //    }
    
}


