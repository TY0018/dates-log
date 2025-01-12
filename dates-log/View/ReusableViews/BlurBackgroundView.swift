//
//  BlurBackgroundView.swift
//  dates-log
//
//  Created by Tong Ying on 11/1/25.
//

import Foundation
import SwiftUI

struct BlurBackgroundView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: .systemMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return blurView
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        // No updates needed
    }
}
