//
//  NavigationProvider.swift
//  News
//
//  Created by Dominic Harrison on 25/06/2022.
//

import Foundation
import UIKit

public enum NavigationDestination: Equatable, Hashable {
    case articleDetail(UIArticle)
}
    
public protocol NavigationProvider: AnyObject {
    func navigate(to destination: NavigationDestination, from sender: UIViewController)
}
