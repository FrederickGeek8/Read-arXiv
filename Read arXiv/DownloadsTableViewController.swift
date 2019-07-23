//
//  DownloadsTableViewController.swift
//  arXiv Reader
//
//  Created by Frederick Morlock on 7/21/19.
//  Copyright © 2019 Frederick Morlock. All rights reserved.
//

import UIKit

struct Article: Decodable {
    var title: String
    var description: String
    var authors: String
    var id: String
}

class DownloadsTableViewController: UITableViewController {
    var articles: [(article: Article, access: Bool)] = []
    var selectedArticle: (article: Article, access: Bool)?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.navigationItem.title = "Bookmarks"
        scanForFiles()
        NotificationCenter.default.addObserver(self, selector: #selector(scanForFiles), name: .init(rawValue: "documentsChanged"), object: nil)
    }
    
    @objc
    func scanForFiles() {
        let fileManager = FileManager.default
        articles = []
        let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            let decoder = JSONDecoder()
            for file in fileURLs {
                if file.pathExtension == "json" {
                    let data = try Data(contentsOf: file)
                    let article = try decoder.decode(Article.self, from: data)
                    articles.append((article, false))
                }
            }
        } catch _ {
            print("Failed to list files")
        }
        
        for i in 0..<articles.count {
            let url = documentURL.appendingPathComponent(articles[i].article.id + ".pdf")
            if fileManager.fileExists(atPath: url.path) {
                articles[i].access = true
            }
        }
        
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return articles.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        
        cell.textLabel?.text = self.articles[indexPath.row].article.title
        cell.textLabel?.numberOfLines = 0
        
        cell.detailTextLabel?.text = self.articles[indexPath.row].article.authors
        cell.detailTextLabel?.numberOfLines = 0
        
        cell.accessoryType = .disclosureIndicator
        
        if !self.articles[indexPath.row].access {
            cell.textLabel?.isEnabled = false
            cell.detailTextLabel?.isEnabled = false
        }
        
        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedArticle = self.articles[indexPath.row]
        self.performSegue(withIdentifier: "downloadView", sender: self)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let dest = segue.destination as? ArticleViewController {
            dest.access = selectedArticle!.access
            dest.article_2 = selectedArticle!.article
        }
    }

}
