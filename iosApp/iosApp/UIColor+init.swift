//
//  UIColor+init.swift
//  iosApp
//
//  Created by Hoc Nguyen T. on 7/17/22.
//  Copyright © 2022 orgName. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
  convenience init?(hexString: String) {
    let hex = hexString
      .trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    
    var int = UInt64()
    Scanner(string: hex).scanHexInt64(&int)

   
    let argb:(a: UInt64, r: UInt64, g: UInt64, b: UInt64)
    switch hex.count {
    case 3: // RGB (12-bit)
      argb = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
    case 6: // RGB (24-bit)
      argb = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
    case 8: // ARGB (32-bit)
      argb = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
    default:
      return nil
    }
    let (a, r, g, b) = argb
    
    self.init(
      red: CGFloat(r) / 255,
      green: CGFloat(g) / 255,
      blue: CGFloat(b) / 255,
      alpha: CGFloat(a) / 255
    )
  }
}
