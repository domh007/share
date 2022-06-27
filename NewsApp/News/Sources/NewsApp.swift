//
//  NewsApp.swift
//  News
//
//  Created by Dominic Harrison on 25/06/2022.
//

import SwiftUI

@main
struct NewsApp: App {
    var body: some Scene {
        WindowGroup {
            NewsView(NewsViewModel(newsService: NYTNewsService()))
        }
    }
}
