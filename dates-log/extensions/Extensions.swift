//
//  Extensions.swift
//  dates-log
//
//  Created by Tong Ying on 7/9/24.
//

import Foundation
import UIKit
import SwiftUI

extension UIApplication{
    func rootController()->UIViewController{
        guard let window = connectedScenes.first as? UIWindowScene else{return .init()}
        guard let viewcontroller = window.windows.last?.rootViewController else{return .init()}
        
        return viewcontroller
    }
}


extension Encodable {
    func asDictionary() -> [String: Any] {
        guard let data = try? JSONEncoder().encode(self) else {
            return [:]
        }
        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [String:Any]
            return json ?? [:]
        } catch {
            return [:]
        }
    }
}

extension UITabBar {
    static func setTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
//        // Set the background color of the Tab Bar
//        appearance.backgroundColor = Color("Purple") // Set your desired color here
//
//        // Set the color for selected tab items (icon and text)
//        UITabBar.appearance().tintColor = UIColor.red
//        
//        // Set the color for unselected tab items (icon and text)
//        UITabBar.appearance().unselectedItemTintColor = UIColor.gray

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance // This makes sure it also works for scrollable content.
    }
}
