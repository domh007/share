//
//  NYTNewsServiceTest.swift
//  News
//
//  Created by Dominic Harrison on 25/06/2022.
//

import XCTest
@testable import News

class NYTNewsServiceTest: XCTestCase {
    
    var sut: NYTNewsService!
    let apiURL = URL(string: "https://api.nytimes.com/svc/topstories/v2/arts.json?api-key=sGecvmIXM2UIIH8QoGslprpSbAvWTqNi")!
    
    class MockNewsServiceObserver : NewsObserver {
        var expectation: XCTestExpectation?
        var articles: [NewsArticle]?
        var error: Error?
        
        init(expectation: XCTestExpectation?) {
            self.expectation = expectation
        }
        
        func articlesReceived(articles: [NewsArticle]) {
            self.articles = articles
            expectation?.fulfill()
        }
        
        func error(error: Error) {
            self.error = error
            expectation?.fulfill()
        }
    }
    
    func setupAPITestFixtures() {
        let bundle = Bundle(for: type(of: self))
        if let filePath = bundle.url(forResource: "NYTFeed", withExtension: "json") {
            
            do {
                let data = try Data(contentsOf: filePath)
                MockURLProtocol.requestHandler = { request in
                    guard let url = request.url, url == self.apiURL else {
                        // Boiler plate error handling
                        throw NSError()
                    }
                    
                    let response = HTTPURLResponse(url: self.apiURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
                    return (response, data)
                }
            } catch {
                print("Can not load JSON file.")
            }
        }
    }
    
    func setupAPIFailure() {
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url, url == self.apiURL else {
                // Boiler plate error handling
                throw NSError()
            }
            
            let response = HTTPURLResponse(url: self.apiURL, statusCode: 400, httpVersion: nil, headerFields: nil)!
            return (response, nil)
        }
    }
    
    override func setUp() {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession.init(configuration: configuration)
        sut = NYTNewsService(session: urlSession)
    }
    
    func testCreateNYTNewsService() {
        XCTAssert(sut != nil)
    }
    
    @MainActor func testDelegateSet() {
        let mockDelegate = MockNewsServiceObserver(expectation: nil)
        let sut = NYTNewsService()
        sut.setFeedDelegate(delegate: mockDelegate)
        XCTAssertTrue(sut.delegate != nil, "NYTNewsService delegate should be set")
    }
    
    @MainActor func testServiceProcessesExpectedResult() {
        setupAPITestFixtures()
        let expectation = expectation(description: "Waiting for service to return with results")
        let mockDelegate = MockNewsServiceObserver(expectation: expectation)
        sut.setFeedDelegate(delegate: mockDelegate)
        sut.fetchArticles()
        
        waitForExpectations(timeout: 10)
        
        XCTAssertTrue(mockDelegate.error == nil, "Decoding error should be nil")
        XCTAssertTrue(mockDelegate.articles?.count == 38, "There should be 38 articles mocked")
    }
    
    @MainActor func testServiceDecodingErrorResult() {
        setupAPIFailure()
        let expectation = expectation(description: "Waiting for service to return with error")
        let mockDelegate = MockNewsServiceObserver(expectation: expectation)
        sut.setFeedDelegate(delegate: mockDelegate)
        sut.fetchArticles()
        
        waitForExpectations(timeout: 10)
        
        XCTAssertTrue(mockDelegate.error != nil, "Decoding error should not be nil")
        XCTAssertTrue(mockDelegate.articles == nil, "articles should be nil")
    }
}
