//
//  AppearanceHelper.swift
//  Surfbox
//
//  Created by Moses Robinson on 3/15/19.
//  Copyright © 2019 Moses Robinson. All rights reserved.
//

import UIKit

enum AppearanceHelper {
    
    // MARK: - Theme Colors
    
    static var darkNavy = UIColor(red:0.07, green:0.11, blue:0.18, alpha:1.00)
    static var paperWhite = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.00)
    static var inkBlack = UIColor(red:0.49, green:0.52, blue:0.53, alpha:1.00)
    static var softOrange = UIColor(red:0.84, green:0.25, blue:0.15, alpha:1.00)
    
    //MARK: - Theme Setup
    
    static func setAppearance() {
        UINavigationBar.appearance().barTintColor = darkNavy
        UIBarButtonItem.appearance().tintColor = softOrange
        UITabBar.appearance().tintColor = darkNavy
        UITabBar.appearance().backgroundColor = darkNavy
        
        UITextField.appearance().tintColor = paperWhite
        UITextView.appearance().tintColor = inkBlack
        
        let textAttributes = [NSAttributedString.Key.foregroundColor: paperWhite]
        
        UINavigationBar.appearance().titleTextAttributes = textAttributes
        UINavigationBar.appearance().largeTitleTextAttributes = textAttributes
        
    }
}
