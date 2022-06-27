//
//  NewsViewModelTests.swift
//  News
//
//  Created by Dominic Harrison on 25/06/2022.
//

import XCTest
@testable import News

private struct TestNewsArticle: Codable, NewsArticle {
    let section: String
    let title: String
    let byline: String
    let date: Date
    let url: String
    var imageUrlString: String?
}

class NewsViewModelTests: XCTestCase {
    class MockNoProgressNewsService: NewsServiceInterface {
        var articlesRequested = false;
        func setFeedDelegate(delegate: NewsObserver) {}
        func getArticles() {}
    }
    
    class MockServiceRequestedGetArticlesNewsService: NewsServiceInterface {
        var articlesRequested = false;
        func setFeedDelegate(delegate: NewsObserver) {}
        func getArticles() { articlesRequested = true }
    }
    
    class MockRespondWithArticlesNewsService: NewsServiceInterface {
        var modelInterface: NewsObserver?
        var articlesRequested = false;
        func setFeedDelegate(delegate: NewsObserver) {
            self.modelInterface = delegate
        }
        func getArticles() {
            let article = TestNewsArticle(section: "section",
                                      title: "test title",
                                      byline: "test byline",
                                      date: Date(timeIntervalSince1970: 1656326456),
                                      url: "http://bbc.co.uk",
                                      imageUrlString: "http://bbc.co.uk/imageUrl")
            DispatchQueue.main.asyncAfter(deadline:.now() + 0.5)  {
                self.modelInterface?.articlesReceived(articles: [article])
            }
        }
    }
    
    @MainActor func testInitialStateIsLoading() throws {
        let sut = NewsViewModel(newsService: MockNoProgressNewsService())
        XCTAssertEqual(sut.loadingState, .loading("loading...") )
    }
    
    @MainActor func testInitialStateRequestsArticles() throws {
        let service = MockServiceRequestedGetArticlesNewsService()
        let sut = NewsViewModel(newsService: service)
        switch sut.loadingState {
        case .error(_), .undefined, .articlesAvailabe(_):
            XCTAssert(false)
        case .loading(_):
            XCTAssert(true)
        }
    }
    
    @MainActor func testResponseWithArticlesReceived() throws {
        let exp = expectation(description: "Loading articles")
        let service = MockRespondWithArticlesNewsService()
        let sut = NewsViewModel(newsService: service)
        let subscription = sut.$loadingState
            .dropFirst()
            .sink{ value in
                exp.fulfill()
            }
        
        switch sut.loadingState {
        case .error(_), .undefined, .articlesAvailabe(_):
            XCTAssert(false)
        case .loading(_):
            XCTAssert(true)
        }

        waitForExpectations(timeout: 10)
        
        switch sut.loadingState {
        case .articlesAvailabe(let articles):
            XCTAssertTrue(articles[0].section == "section", "Test section not set correctly")
            XCTAssertTrue(articles[0].title == "test title", "Test title not set correctly")
            XCTAssertTrue(articles[0].byline == "test byline", "Test byline not set correctly")
            XCTAssertTrue(articles[0].date == Date(timeIntervalSince1970: 1656326456), "Test date not set correctly")
            XCTAssertTrue(articles[0].url == "http://bbc.co.uk", "Test url not set correctly")
            XCTAssertTrue(articles[0].thumbnail == "http://bbc.co.uk/imageUrl", "Test thumbnail not set correctly")
            
        case .error(_), .undefined, .loading(_):
            XCTAssert(false)
        }
        
        subscription.cancel()
    }
}
