//
//  Figur8BaseConfiguration.swift
//  F8SDK
//
//  Created by YICHUN ZHANG on 2/26/18.
//

import UIKit

open class Figur8BaseConfiguration {
    
    /// A handle to the next view controller to load when the user clicks continue
    private var postVC: UIViewController?
    
    /// A handle to this view controller
    public private(set) var viewController: UIViewController!
    
    /// Returns the view controller associated with this class
    public func getViewControllerInstance() -> UIViewController {
        return viewController
    }
    
    /// Default contstructor
    public init(storyBoardName: String, storyBoardBundle: Bundle = Utils.sharedInstance.getF8SdkResourceBundle()){
        self.setViewController(storyBoardName: storyBoardName, storyBoardBundle: storyBoardBundle)
    }
    
    /// Allows someone to change the viewController associated with this view configuration
    public func setViewController(storyBoardName: String, storyBoardBundle: Bundle){
        let storyboard = UIStoryboard(name: storyBoardName, bundle: storyBoardBundle)
        self.viewController = storyboard.instantiateViewController(withIdentifier: storyBoardName)
    }
    
    /// This is the view controller to load after pairing is complete
    public var postViewController: UIViewController?  {
        get{
            return self.postVC
        }set(value) {
            self.postVC = value
        }
    }
}
