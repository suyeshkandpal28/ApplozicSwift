//
//  UINavigationController+LoadConfiguration.swift Go to file .swift
//  Applozic
//
//  Created by Suyesh Kandpal on 29/09/20.
//

import UIKit

extension UINavigationController{
    func loadConfigurations(_ configuration : ALKConfiguration) {
        self.navigationBar.barTintColor = configuration.navigationBarBackgroundColor
        self.navigationBar.tintColor = configuration.navigationBarItemColor
        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : configuration.navigationTitleColor]
        self.navigationBar.isTranslucent = false
        if configuration.hideNavigationBarBottomLine {
            self.navigationBar.hideBottomHairline()}
    }
}
