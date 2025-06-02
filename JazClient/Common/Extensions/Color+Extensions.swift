//
//  Color+Extensions.swift
//  Khawi
//
//  Created by Karim Amsha on 20.10.2023.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    static func primary() -> Color {
        return Color(hex: "ED8911") // اللون الرئيسي
    }

    static func primary1() -> Color {
        return Color(hex: "F29C29") // أفتح شوي
    }

    static func primary2() -> Color {
        return Color(hex: "D67C0F") // أغمق شوي
    }

    static func primaryNormal() -> Color {
        return Color(hex: "ED8911") // ثابت
    }

    static func primaryLight() -> Color {
        return Color(hex: "FFE0B3") // خلفيات خفيفة
    }

    static func primaryLightHover() -> Color {
        return Color(hex: "FFCA80") // حالة hover
    }

    static func primaryLightActive() -> Color {
        return Color(hex: "FFB74D") // حالة الضغط
    }
    
    // ✅ خلفيات إضافية من الصور
    static func backgroundF3F3F3() -> Color {
        return Color(hex: "F3F3F3")
    }

    static func backgroundFEF3DE() -> Color {
        return Color(hex: "FEF3DE")
    }

    static func backgroundFEFEFE() -> Color {
        return Color(hex: "FEFEFE")
    }
    
    static func yellowF8B22A() -> Color {
        return Color(hex: "F8B22A")
    }

    static func yellowFFF3D9() -> Color {
        return Color(hex: "FFF3D9")
    }

    // ✅ Gradients
    static func primaryGradientColor() -> LinearGradient {
        let colors = [Color.primary1(), Color.primary2()]
        return LinearGradient(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    static func grayGradientColor() -> LinearGradient {
        let colors = [Color.grayF8F8F8(), Color.grayF8F8F8()]
        return LinearGradient(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    static func GetGradientBGColor() -> LinearGradient {
        let colors = [Color.primary(), Color.primary()]
        return LinearGradient(gradient: Gradient(colors: colors), startPoint: .bottom, endPoint: .top)
    }

    static func GetGradientWhiteColor() -> LinearGradient {
        let colors = [Color.white, Color.white]
        return LinearGradient(gradient: Gradient(colors: colors), startPoint: .top, endPoint: .bottom)
    }

    static
    func primaryDark() -> Color {
        return Color(hex: "043356")
    }

    static
    func primaryDarker() -> Color {
        return Color(hex: "021828")
    }

    static
    func secondary() -> Color {
        return Color(hex: "00A991")
    }
    
    static
    func secondaryLight() -> Color {
        return Color(hex: "E6F6F4")
    }

    static
    func secondaryLightActive() -> Color {
        return Color(hex: "B0E4DD")
    }

    static
    func secondaryLightHover() -> Color {
        return Color(hex: "D9F2EF")
    }

    static
    func secondaryDark() -> Color {
        return Color(hex: "007F6D")
    }

    static
    func secondaryDarker() -> Color {
        return Color(hex: "003B33")
    }
    
    static
    func cyan() -> Color {
        return Color(hex: "00A5B9")
    }

    static
    func black131313() -> Color {
        return Color(hex: "131313")
    }
    
    static
    func black1C1C28() -> Color {
        return Color(hex: "1C1C28")
    }
    
    static
    func black1A1C1E() -> Color {
        return Color(hex: "1A1C1E")
    }
    
    static
    func black222020() -> Color {
        return Color(hex: "222020")
    }

    static
    func primaryBlack() -> Color {
        return Color(hex: "1A1A1A")
    }

    static
    func black1A1818() -> Color {
        return Color(hex: "1A1818")
    }
    
    static
    func black292D32() -> Color {
        return Color(hex: "292D32")
    }

    static
    func black0C0B0B() -> Color {
        return Color(hex: "0C0B0B")
    }

    static
    func black1C2433() -> Color {
        return Color(hex: "1C2433")
    }

    static
    func black141F1F() -> Color {
        return Color(hex: "141F1F")
    }
    
    static
    func black4E5556() -> Color {
        return Color(hex: "4E5556")
    }
    
    static
    func black151515() -> Color {
        return Color(hex: "151515")
    }
    
    static
    func black1F1F1F() -> Color {
        return Color(hex: "1F1F1F")
    }
    
    static
    func black0B0B0B() -> Color {
        return Color(hex: "0B0B0B")
    }

    static
    func black121212() -> Color {
        return Color(hex: "121212")
    }

    static
    func black666666() -> Color {
        return Color(hex: "666666")
    }
        
    static
    func gray898989() -> Color {
        return Color(hex: "898989")
    }
    
    static
    func grayB6B6B6() -> Color {
        return Color(hex: "B6B6B6")
    }

    static
    func grayDCDCDC() -> Color {
        return Color(hex: "DCDCDC")
    }
    
    static
    func gray737373() -> Color {
        return Color(hex: "737373")
    }

    static
    func grayEFEFEF() -> Color {
        return Color(hex: "EFEFEF")
    }

    static
    func grayF2F2F2() -> Color {
        return Color(hex: "F2F2F2")
    }

    static
    func grayCCCCCC() -> Color {
        return Color(hex: "CCCCCC")
    }

    static
    func grayE8EBF3() -> Color {
        return Color(hex: "E8EBF3")
    }
    
    static
    func grayEBF0FF() -> Color {
        return Color(hex: "EBF0FF")
    }

    static
    func gray848DA3() -> Color {
        return Color(hex: "848DA3")
    }

    static
    func grayE8E8E8() -> Color {
        return Color(hex: "E8E8E8")
    }
    
    static
    func grayDDDFDF() -> Color {
        return Color(hex: "DDDFDF")
    }
    
    static
    func grayD8E2FF() -> Color {
        return Color(hex: "D8E2FF")
    }
    
    static
    func gray4E5556() -> Color {
        return Color(hex: "4E5556")
    }

    static
    func grayF8FAFB() -> Color {
        return Color(hex: "F8FAFB")
    }

    static
    func grayD2D2D2() -> Color {
        return Color(hex: "D2D2D2")
    }

    static
    func grayFBFBFB() -> Color {
        return Color(hex: "FBFBFB")
    }

    static
    func grayF9FAFA() -> Color {
        return Color(hex: "F9FAFA")
    }

    static
    func grayE6E9EA() -> Color {
        return Color(hex: "E6E9EA")
    }

    static
    func grayFFF7E9() -> Color {
        return Color(hex: "FFF7E9")
    }

    static
    func gray918A8A() -> Color {
        return Color(hex: "918A8A")
    }
    
    static
    func grayA4ACAD() -> Color {
        return Color(hex: "A4ACAD")
    }
    
    static
    func gray8F8F8F() -> Color {
        return Color(hex: "8F8F8F")
    }

    static
    func grayECECEC() -> Color {
        return Color(hex: "ECECEC")
    }
    
    static
    func gray595959() -> Color {
        return Color(hex: "595959")
    }
    
    static
    func gray9098B1() -> Color {
        return Color(hex: "9098B1")
    }

    static
    func gray6C7278() -> Color {
        return Color(hex: "6C7278")
    }

    static
    func grayA1A1A1() -> Color {
        return Color(hex: "A1A1A1")
    }
    
    static
    func grayF9F9F9() -> Color {
        return Color(hex: "F9F9F9")
    }
    
    static
    func grayF8F8F8() -> Color {
        return Color(hex: "F8F8F8")
    }
    
    static
    func grayDEDEDE() -> Color {
        return Color(hex: "DEDEDE")
    }
    
    static
    func grayE6E6E6() -> Color {
        return Color(hex: "E6E6E6")
    }

    static
    func grayF5F5F5() -> Color {
        return Color(hex: "F5F5F5")
    }
    
    static
    func gray303437() -> Color {
        return Color(hex: "303437")
    }

    static
    func gray999999() -> Color {
        return Color(hex: "999999")
    }

    static
    func grayA5A5A5() -> Color {
        return Color(hex: "A5A5A5")
    }
    
    static
    func grayF2F2F3() -> Color {
        return Color(hex: "F2F2F3")
    }
    
    static
    func grayF2F4F5() -> Color {
        return Color(hex: "F2F4F5")
    }

    static
    func gray929292() -> Color {
        return Color(hex: "929292")
    }
    
    static
    func blue3784B1() -> Color {
        return Color(hex: "3784B1")
    }
    
    static
    func blue288599() -> Color {
        return Color(hex: "288599")
    }

    static
    func blue0094FF() -> Color {
        return Color(hex: "0094FF")
    }
    
    static
    func blue006E85() -> Color {
        return Color(hex: "006E85")
    }
    
    static
    func blue068DA9() -> Color {
        return Color(hex: "068DA9")
    }
    
    static
    func blue057E98() -> Color {
        return Color(hex: "057E98")
    }
    
    static
    func blueE6F3F6() -> Color {
        return Color(hex: "E6F3F6")
    }

    static
    func blue0070F0() -> Color {
        return Color(hex: "0070F0")
    }

    static
    func blue3A70E2() -> Color {
        return Color(hex: "3A70E2")
    }
    
    static
    func blueEBF0FC() -> Color {
        return Color(hex: "EBF0FC")
    }

    static
    func blueLight() -> Color {
        return Color(hex: "E0F8FE")
    }

    static
    func green0CB057() -> Color {
        return Color(hex: "0CB057")
    }
    
    static
    func successNormal() -> Color {
        return Color(hex: "009402")
    }

    static
    func successDark() -> Color {
        return Color(hex: "006F02")
    }
    
    static
    func successLight() -> Color {
        return Color(hex: "E6F4E6")
    }

    static
    func dangerNormal() -> Color {
        return Color(hex: "940000")
    }

    static
    func dangerDarker() -> Color {
        return Color(hex: "340000")
    }

    static
    func dangerLight() -> Color {
        return Color(hex: "F4E6E6")
    }

    static
    func primaryGreen() -> Color {
        return Color(hex: "209811")
    }

    static
    func green0C9D61() -> Color {
        return Color(hex: "0C9D61")
    }
    
    static
    func greenE6F5EF() -> Color {
        return Color(hex: "E6F5EF")
    }
    
    static
    func green46CF85() -> Color {
        return Color(hex: "46CF85")
    }
    
    static
    func orangeFEF4E8() -> Color {
        return Color(hex: "FEF4E8")
    }

    static
    func orangeD67200() -> Color {
        return Color(hex: "D67200")
    }

    static
    func orangeFDE9D1() -> Color {
        return Color(hex: "FDE9D1")
    }

    static
    func orangeF7941D() -> Color {
        return Color(hex: "F7941D")
    }
    
    static
    func orangeFCE5E5() -> Color {
        return Color(hex: "FCE5E5")
    }

    static
    func orangeCA5D08() -> Color {
        return Color(hex: "CA5D08")
    }

    static
    func orangeF6E5D0() -> Color {
        return Color(hex: "F6E5D0")
    }

    static
    func redFF5B5B() -> Color {
        return Color(hex: "FF5B5B")
    }

    static
    func redFF3F3F() -> Color {
        return Color(hex: "FF3F3F")
    }
    
    static
    func redFAE8E8() -> Color {
        return Color(hex: "FAE8E8")
    }

    static
    func redCA1616() -> Color {
        return Color(hex: "CA1616")
    }

    static
    func redE50000() -> Color {
        return Color(hex: "E50000")
    }
    
    static
    func yellowFFB020() -> Color {
        return Color(hex: "FFB020")
    }
    
    static
    func yellowFFFCF6() -> Color {
        return Color(hex: "FFFCF6")
    }
    
    static
    func background() -> Color {
        return Color(hex: "FAFAFA")
    }    
}

public extension Color {

    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
    
    static var random: Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}
