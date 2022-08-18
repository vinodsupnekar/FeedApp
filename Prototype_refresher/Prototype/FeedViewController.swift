//
//  FeedViewController.swift
//  Prototype
//
//  Created by vinods.alt on 18/08/22.
//

import Foundation
import UIKit

class FeedViewController: UITableViewController{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "FeedImageCell", for: indexPath)
    }
}
