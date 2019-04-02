//
//  F8ColorScheme.swift
//  F8SDK
//
//  Created by Jing Wang on 8/3/18.
//
import UIKit

public struct F8ColorScheme {
    private static let BLACK = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    private static let BLUE = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
    private static let BROWN = #colorLiteral(red: 0.6679978967, green: 0.4751212597, blue: 0.2586010993, alpha: 1)
    private static let CYAN = #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1)
    private static let GREEN = #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1)
    private static let MAGENTA = #colorLiteral(red: 1, green: 0.2527923882, blue: 1, alpha: 1)
    private static let ORANGE = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
    private static let PURPLE = #colorLiteral(red: 0.5791940689, green: 0.1280144453, blue: 0.5726861358, alpha: 1)
    private static let RED = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
    private static let YELLOW = #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1)
    private static let WHITE = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
    private static let CLEAR = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 0)
    private static let GRAY85 = #colorLiteral(red: 0.8470588235, green: 0.8470588235, blue: 0.8470588235, alpha: 1)
    private static let GRAY80 = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    private static let GRAY60 = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
    private static let GRAY50 = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
    private static let GRAY25 = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    
    public static var NOTSELECTED_BUTTON_TITLE: UIColor { return BLACK }
    public static var SELECTED_BUTTON_TITLE: UIColor { return GRAY80 }
    public static var DEFAULT_BACKGROUND_DAY: UIColor {return WHITE}
    public static var DEFAULT_BACKGROUND_NIGHT: UIColor {return BLACK}
    public static var DEFAULT_BACKGROUND_CATEGORY_TAG_BUTTON: UIColor {return GRAY80}
    public static var DEFAULT_CLEAR: UIColor {return CLEAR}
    public static var DEFAULT_TITLE_TEXT_ENABLED: UIColor {return BLACK}
    public static var DEFAULT_SUBTITLE_TEXT_ENABLED: UIColor {return GRAY60}
    public static var DEFAULT_TITLE_TEXT_DISABLED: UIColor {return GRAY60}
    public static var DEFAULT_SUBTITLE_TEXT_DISABLED: UIColor {return GRAY85}
    public static var LOGO_SCHEME_V1: UIColor { return #colorLiteral(red: 0.9245442748, green: 0.2043415904, blue: 0.1473782957, alpha: 1) }
    
    // Color schems for categoryTagBtn related
    public static var COLORTAG_COLOR_DEFAULT: UIColor { return GRAY85}
    public static var COLORTAG_COLOR_OPTION1: UIColor { return #colorLiteral(red: 0.2901960784, green: 0.6784313725, blue: 1, alpha: 1)}
    public static var COLORTAG_COLOR_OPTION2: UIColor { return #colorLiteral(red: 0.4901960784, green: 0.9411764706, blue: 0.6666666667, alpha: 1)}
    public static var COLORTAG_COLOR_OPTION3: UIColor { return #colorLiteral(red: 1, green: 0.7411764706, blue: 0.3215686275, alpha: 1)}
    public static var COLORTAG_COLOR_OPTION4: UIColor { return #colorLiteral(red: 0.9960784314, green: 0.06666666667, blue: 0.01176470588, alpha: 1)}
    
    public static var CATEGORY_BUTTON_BACKGROUND_COLOR_DEFAULT: UIColor { return #colorLiteral(red: 0.9289377224, green: 0.5300190498, blue: 1, alpha: 1) }
    
    public static var BUTTON_TITLE_WEIGHT: UIFont.Weight { return .medium }
    
    
    public init(){}
}
