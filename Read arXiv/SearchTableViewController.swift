//
//  SearchTableViewController.swift
//  Read arXiv
//
//  Created by Frederick Morlock on 8/2/19.
//  Copyright © 2019 Frederick Morlock. All rights reserved.
//

import UIKit
import FeedKit

class SearchTableViewController: UITableViewController {
    
    var feed: AtomFeed?
    var selectedArticle: AtomFeedEntry?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for Article"
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        self.title = "Search"
        definesPresentationContext = true
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.feed?.entries?.count ?? 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        
        if self.feed == nil || self.feed?.entries?.count == 0 {
            cell.textLabel?.text = "Nothing to display."
            cell.textLabel?.numberOfLines = 0
            return cell
        }
        
        cell.textLabel?.text = self.feed?.entries?[indexPath.row].title
        cell.textLabel?.numberOfLines = 0
        var authors = ""
        let raw_authors = self.feed?.entries?[indexPath.row].authors ?? []
        for author in raw_authors {
            authors += (author.name ?? "") + " "
        }
        
        cell.detailTextLabel?.text = authors
        cell.detailTextLabel?.numberOfLines = 0
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedArticle = self.feed?.entries?[indexPath.row]
        self.performSegue(withIdentifier: "articleView2", sender: self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let dest = segue.destination as? ArticleViewController {
            dest.article = selectedArticle
        }
    }
    

}

extension SearchTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}

extension SearchTableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let query = searchBar.text?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)?.replacingOccurrences(of: "%20", with: "+")
        
        
        let api = URL(string: "https://export.arxiv.org/api/query?search_query=ti:%22\(query!)%22&sortBy=relevance&max_results=100")
        print(api)
        let parser = FeedParser(URL: api!)
        
        parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { (result) in
            self.feed = result.atomFeed
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
    }
}
