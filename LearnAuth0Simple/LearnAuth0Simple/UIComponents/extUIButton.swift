import UIKit

extension UIButton
{
    func addBlurEffect() {
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blur.accessibilityLabel = "blurView"
        blur.frame = self.bounds
        blur.alpha = 0.95
        blur.isUserInteractionEnabled = false
        self.insertSubview(blur, at: 0)
        if let imageView = self.imageView {
            self.bringSubview(toFront: imageView)
        }
    }
}
