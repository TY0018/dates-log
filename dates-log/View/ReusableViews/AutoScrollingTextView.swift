//
//  AutoScrollingView.swift
//  dates-log
//
//  Created by Tong Ying on 17/1/25.
//

import Foundation
import SwiftUI

struct AutoScrollingTextView: UIViewRepresentable {
    let text: String
    let duration: Double
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 18)
        label.sizeToFit()
        
        scrollView.addSubview(label)
        scrollView.contentSize = label.bounds.size
        scrollView.isUserInteractionEnabled = false
        
        // Set up animation
        DispatchQueue.main.async {
                    if label.bounds.width > scrollView.bounds.width {
                        let offset = CGPoint(x: label.bounds.width - scrollView.bounds.width, y: 0)
                        UIView.animate(withDuration: duration, delay: 0, options: [.repeat, .curveLinear]) {
                            scrollView.contentOffset = offset
                        }
                    }
                }
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {}
}
