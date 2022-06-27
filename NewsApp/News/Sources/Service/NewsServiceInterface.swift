//
//  NewsServiceInterface.swift
//  News
//
//  Created by Dominic Harrison on 27/06/2022
//

import Foundation


// Implement this protocol in an async service that provides feed articles.
protocol NewsServiceInterface: AnyObject {
    // Sets the NewsObserver delegate in the news service interface. The NewsObserver uses the data returrnd back from the NewsService.
    func setFeedDelegate(delegate: NewsObserver)
    // Calling this method initiates an (sync) fetch of articles from the news service.
    func getArticles()
}

// This protocol is the type of the delegate in NewsServiceInterface to notify observers that feed articles are available,
// or that there was an error in the service.
// Add an delegate of this type in your NewsServiceInterface to process received data.
// When the articles are received call the articlesReceived(...) to supply the articles to the client.  If an error occurs in the service, call error(...)
@MainActor protocol NewsObserver: AnyObject {
    // Tells the delegate that the service has received an array of NewsArticle
    @MainActor func articlesReceived(articles: [NewsArticle])
    // Tells the delegate that the service experienced an error
    @MainActor func error(error: Error)
}

// Articles coming from the different services must conform to this protocol.
// Transform the service specific articles to provide generic data conforming to this protocol.
protocol NewsArticle {
    var section: String { get }
    var title: String { get }
    var byline: String { get }
    var date: Date { get }
    var url: String { get }
    var imageUrlString: String? { get }
}
