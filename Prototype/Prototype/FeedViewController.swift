//
//  FeedViewController.swift
//  Prototype
//
//  Created by vinod supnekar on 20/03/21.
//

import UIKit

struct FeedImageViewModel {
    let description: String?
    let location: String?
    let imageName: String?
}

class FeedViewController: UITableViewController {

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedImageCell")!

        // Configure the cell...

        return cell
    }
    

   
}
