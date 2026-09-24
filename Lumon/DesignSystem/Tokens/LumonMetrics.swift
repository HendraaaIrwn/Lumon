import CoreGraphics

enum LumonSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let smPlus: CGFloat = 12
    static let md: CGFloat = 16
    static let mdPlus: CGFloat = 20
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xlPlus: CGFloat = 40
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
}

enum LumonRadius {
    static let none: CGFloat = 0
    static let small: CGFloat = 4
    static let medium: CGFloat = 8
    static let large: CGFloat = 12
}

enum LumonStroke {
    static let thin: CGFloat = 2
    static let medium: CGFloat = 4
    static let bold: CGFloat = 6
    static let hero: CGFloat = 8
}

enum LumonTouchTarget {
    static let minimum: CGFloat = 44
    static let primaryButtonHeight: CGFloat = 56
    static let colorButtonCompact: CGFloat = 56
    static let colorButtonRegular: CGFloat = 64
}
