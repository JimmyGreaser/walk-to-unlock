import Foundation

enum AppConstants {
    static let bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.jimmygreaser.WalkToUnlock"
    static let stepCheckTaskIdentifier = "\(bundleIdentifier).stepcheck"
    static let reblockTaskIdentifier = "\(bundleIdentifier).reblock"
}
