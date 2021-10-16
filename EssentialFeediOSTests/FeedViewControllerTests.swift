//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by vinod supnekar on 20/08/21.
//  Copyright © 2021 VinodS. All rights reserved.
//
 
import XCTest
import EssentialFeed
import EssentialFeediOS

class FeedViewControllerTests: XCTestCase {

    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadFeedCallCount, 0, "expeted no loading request before view is loaded")

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected a loading request once view is loaded")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 2, "Expected another loading request once user initiates a load")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 3, "Expected third loading request once user initiates another  load")
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        XCTAssertTrue(sut.isShowingLoadingIndicator, "expect loading indicator once view is loaded")
    
        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading is copleted successfully")
    
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once loading is completed")
     
        loader.completeFeedLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once use initiated loading copletes with error")
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let image0 = makeImage(description: "a description", location: "a location")
        let image1 = makeImage(description: nil, location: "a location")
        let image2 = makeImage(description: "a description", location: nil)
        let image3 = makeImage(description: nil, location: nil)

        let (sut, loder) = makeSUT()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering:[])

        loder.completeFeedLoading(with: [image0], at:0)
        assertThat(sut, isRendering:[image0])

        sut.simulateUserInitiatedFeedReload()
        loder.completeFeedLoading(with: [image0,image1,image2,image3], at:1)
        assertThat(sut, isRendering:[image0,image1,image2,image3])

    }
    
    func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOfError() {
        let image0 = makeImage()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoadingWithError(at: 1)
        assertThat(sut, isRendering: [image0])
    }
    
    func test_feedImageView_loadsImageURLWhenvisible() {
        let image0 = makeImage( url: URL(string: "http://url-0.com")!)
        let image1 = makeImage( url: URL(string: "http://url-1.com")!)
        
        let (sut,loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0,image1])

        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no images URL requests until view become visible")
        
        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url], "Expected first image URL request once first view becomes visible")
        
        sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url,image1.url], "Expected first image URL request once first view becomes visible")
    }
    
    func test_feedImageView_cancelsimageLoadingWhenNotVisibleAnymore() {
        let image0 = makeImage( url: URL(string: "http://url-0.com")!)
        let image1 = makeImage( url: URL(string: "http://url-1.com")!)
        
        let (sut,loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0,image1])
        XCTAssertEqual(loader.cancelsImageURLs, [], "Expected no images URL requests until view become visible")
        
        sut.simulateFeedImageViewNotVisible(at: 0)
        XCTAssertEqual(loader.cancelsImageURLs, [image0.url], "Expected first image URL request once first view becomes visible")
        
        sut.simulateFeedImageViewNotVisible(at: 1)
        XCTAssertEqual(loader.cancelsImageURLs,  [image0.url,image1.url],  "Expected first image URL request once first view becomes visible")
    }
    
    
    //MARK:- Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (FeedViewController, LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(feedLoader: loader, imageLoader: loader)
        trackMemoryLeaks(loader,file: file,line: line)
        trackMemoryLeaks(sut,file: file,line: line)
        return (sut, loader)
    }
    
    private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "http://any-url.com")!) -> FeedImage {
        return FeedImage(id: UUID(), description: description, location: location, url: url)
    }
    
    private func assertThat(_ sut: FeedViewController, isRendering feed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        guard sut.numberOfrenderedFeedImageViews()  == feed.count else {
            return XCTFail("Expected \(feed.count) images, got \(sut.numberOfrenderedFeedImageViews()) instead." , file: file, line: line)
        }
        
        feed.enumerated().forEach { (index, image) in
            assertThat(sut, hasViewConfiguredFor: image, at: index)
        }
    }
    
    private func assertThat(_ sut: FeedViewController, hasViewConfiguredFor image: FeedImage, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.feedImageView(at: index)
        
        guard let cell = view as? FeedImageCell else {
           return  XCTFail("Expected \(FeedImageCell.self) instance, got \(String(describing: view)) instead", file: file, line: line )
        }
        
        let shouldLocationBeVisible = (image.location != nil)
        XCTAssertEqual(cell.isShowingLocation, shouldLocationBeVisible, "Expected 'isShowingLocation' to be \(shouldLocationBeVisible) for image at index \(index)",file: file,line: line)
        
        XCTAssertEqual(cell.locationText, image.location, "Expected  location text to be \(String(describing: image.location)) for image at index \(index)",file: file,line: line)
        
        XCTAssertEqual(cell.descritptionText, image.description, "Expected  description text to be \(String(describing: image.description)) for description at index \(index)",file: file,line: line)
    }
    
    class LoaderSpy: FeedLoader, FeedImageDataLoader {
        func cancelImageDataLoaded(from url: URL) {
            cancelsImageURLs.append(url)
        }
        
        private var feedRequests = [(FeedLoader.Result) -> Void]()
        var loadFeedCallCount: Int {
            return feedRequests.count
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            feedRequests.append(completion)
        }
        
        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
            feedRequests[index](.success(feed))
        }
        
        func completeFeedLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error ", code: 0)
            feedRequests[index](.failure(error))
        }
        
        //MARK:- FeedImage Data Loader
        private(set) var loadedImageURLs =  [URL] ()
        private(set) var cancelsImageURLs = [URL]()

        func loadImageData(from url: URL) {
            loadedImageURLs.append(url)
        }
        
        func cancelsImageDateLoad(from url: URL) {
            cancelsImageURLs.append(url)
        }
    }
}

private extension FeedViewController {
    @discardableResult
    func simulateFeedImageViewVisible(at index: Int)  -> FeedImageCell? {
       return  feedImageView(at: index) as? FeedImageCell
    }
    
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    func simulateFeedImageViewNotVisible(at row: Int) {
        let view = simulateFeedImageViewVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImageSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
    }
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
    
    func numberOfrenderedFeedImageViews() -> Int {
        return tableView.numberOfRows(inSection: feedImageSection)
    }
    
    private var feedImageSection: Int {
        return 0
    }
    
    func feedImageView(at row: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: feedImageSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
}

private extension FeedImageCell {
    var isShowingLocation: Bool {
        return !locationContainer.isHidden
    }
    
    var locationText: String? {
        return locationLabel.text
    }
    
    var descritptionText: String? {
        return descritpionLabel.text
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach{ target in
        actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
            (target as NSObject).perform(Selector($0))
      }
     }
    }
}
