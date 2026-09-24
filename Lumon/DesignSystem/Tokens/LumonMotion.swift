import SwiftUI

enum LumonMotion {
    static let tap = Animation.easeOut(duration: 0.12)
    static let selection = Animation.easeOut(duration: 0.20)
    static let reveal = Animation.easeInOut(duration: 0.28)
    static let hint = Animation.easeInOut(duration: 0.32)
    static let wrong = Animation.easeInOut(duration: 0.09)
    static let transition = Animation.easeInOut(duration: 0.20)
}
