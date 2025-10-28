import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Единая утилита проверки наличия ассета по имени.
enum ImageAsset {
    static func exists(_ name: String) -> Bool {
        #if canImport(UIKit)
        return UIImage(named: name) != nil
        #else
        return false
        #endif
    }
}
