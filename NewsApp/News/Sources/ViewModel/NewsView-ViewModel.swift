//
//  NewsView-ViewModel.swift
//  News
//
//  Created by Dominic Harrison on 25/06/2022.
//

import Foundation
import SwiftUI

public struct UIArticle : Hashable {
    let section: String
    let title: String
    let byline: String
    let url: String
    let date: Date
    let thumbnail: String?
}

// View Model
@MainActor class NewsViewModel: ObservableObject, NewsObserver {
    enum ViewState: Equatable  {
        case undefined
        case loading(String)
        case articlesAvailabe([UIArticle])
        case error(String)
    }
    
    @Published var loadingState:ViewState = .undefined
    
    private var newsService: NewsServiceInterface
    private var navigationProvider: NavigationProvider?
    
    init(newsService: NewsServiceInterface) {
        self.newsService = newsService
        newsService.setFeedDelegate(delegate: self)
        requestNewData()
        loadingState = .loading("loading...")
    }
    
    func requestNewData(){
        newsService.getArticles()
    }
    
    func articleTapped(article: UIArticle){
        print("Implement navigation stack handling via some loose coupled navigationProvider for \(article.url)")
    }
    
    // NewsModelInterface
    func error(error: Error) {
        loadingState = .error(error.localizedDescription)
    }
    
    func articlesReceived(articles: [NewsArticle]) {
        // Transform service data into UI data.
        let articles = articles.map { article -> UIArticle in
            return UIArticle(section: article.section,
                             title: article.title,
                             byline: article.byline,
                             url: article.url,
                             date: article.date,
                             thumbnail: article.imageUrlString);
        }
        self.loadingState = .articlesAvailabe(articles)
    }
}

