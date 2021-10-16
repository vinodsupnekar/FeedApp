//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by vinod supnekar on 21/08/21.
//  Copyright © 2021 VinodS. All rights reserved.
//

import UIKit
import EssentialFeed

final public class  FeedViewController: UITableViewController {
    private var loader: FeedLoader?
    private var tableModel =  [FeedImage]()
    
    public convenience init( loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        loader?.load { [weak self]  results in
            self?.tableModel = (try? results.get()) ?? []
            self?.tableView.reloadData()
            self?.refreshControl?.endRefreshing()
        }
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = tableModel[indexPath.row]
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = (cellModel.location == nil)
        cell.locationLabel.text = cellModel.location
        cell.descritpionLabel.text = cellModel.description
        return cell
    }
}
