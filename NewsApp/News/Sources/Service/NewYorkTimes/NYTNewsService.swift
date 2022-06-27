//
//  NewsService.swift
//  News
//
//  Created by Dominic Harrison on 25/06/2022.
//

import Foundation
import UIKit

private struct NYTFeedResponse: Codable {
    let status: String
    let copyright: String
    let section: String
    let last_updated: String
    let num_results: Int
    let results: [NYTNewsArticle]
}

private struct NYTNewsArticle: Codable, NewsArticle {
    let section: String
    let title: String
    let byline: String
    let date: Date
    let url: String
    let multimedia: [ViewableImage]
    
    enum CodingKeys: String, CodingKey {
        case section
        case title
        case byline
        case date = "updated_date"
        case url
        case multimedia
    }
    
    var imageUrlString: String? {
        guard let image = self.multimedia.filter({ viewableImage in
            viewableImage.format == "Large Thumbnail"
        }).first else {
            return nil
        }
        
        return image.url
    }
}

private struct ViewableImage: Codable {
    let url: String
    let format: String
}

class NYTNewsService: NewsServiceInterface {
    weak var delegate: NewsObserver?

    func setFeedDelegate(delegate: NewsObserver) {
        self.delegate = delegate
    }

    func getArticles() {
        guard let url = URL(string: "https://api.nytimes.com/svc/topstories/v2/arts.json?api-key=sGecvmIXM2UIIH8QoGslprpSbAvWTqNi") else { return }
        let task = URLSession.shared.dataTask(with: url, completionHandler: { [weak self] data , _, error in
            
            guard let strongSelf = self else { return }
            guard error == nil else {
                DispatchQueue.main.async {
                    strongSelf.delegate?.error(error: error!)
                }
                return
            }
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let response = try decoder.decode(NYTFeedResponse.self, from: data)
                DispatchQueue.main.async {
                    strongSelf.delegate?.articlesReceived(articles: response.results)
                }
            } catch {
                DispatchQueue.main.async {
                    strongSelf.delegate?.error(error: error)
                }
            }
            
        })
        task.resume()
    }
}

