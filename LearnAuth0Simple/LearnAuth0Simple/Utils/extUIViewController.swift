    
    import UIKit
    
    // Utils
    
    extension UIViewController {
        public func delay(seconds: Double, completion: @escaping ()-> Void) {
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: completion)
        }
    }
