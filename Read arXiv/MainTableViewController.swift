//
//  MainTableViewController.swift
//  arXiv Reader
//
//  Created by Frederick Morlock on 7/19/19.
//  Copyright © 2019 Frederick Morlock. All rights reserved.
//

import UIKit
import FeedKit

class MainTableViewController: UITableViewController {
    var feed: AtomFeed?
    var dateDelta: Int = -1
    var selectedArticle: AtomFeedEntry?
    var indicator = UIActivityIndicatorView()
    var titleView: UIView?
    
    @IBOutlet weak var titleButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        dateDelta = prevDay(delta: dateDelta)
        if nextDay(delta: dateDelta) < -1 {
            dateDelta = nextDay(delta: dateDelta)
        }
        
        titleButton.setTitle(displayDate(delta: dateDelta), for: .normal)
        
        UserDefaults.standard.addObserver(self, forKeyPath: "subscriptions", options: .new, context: nil)
        
        indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - ((self.navigationController?.navigationBar.frame.height)! + UIApplication.shared.statusBarFrame.height)))
        indicator.style = .gray
        indicator.hidesWhenStopped = true
        
        titleView = self.navigationItem.titleView
        
        let (start, end) = getDatePair(delta: dateDelta)
        updateSubscriptions(start: start, end: end)
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
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
            cell.textLabel?.text = "Nothing to display. Add subscriptions or connect to the internet."
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
        
        cell.detailTextLabel?.text = authors.truncate(length: 200)
        cell.detailTextLabel?.numberOfLines = 0
        
        cell.accessoryType = .disclosureIndicator

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedArticle = self.feed?.entries?[indexPath.row]
        self.performSegue(withIdentifier: "articleView", sender: self)
    }
    
    func updateSubscriptions(start: String, end: String) {
        titletoIndicator()
        let subscriptions = UserDefaults.standard.dictionary(forKey: "subscriptions") ?? [:]
        if subscriptions.count != 0 {
            var query = ""
            for pair in subscriptions {
                let value = pair.value as! [String]
                for part in value {
                    query += "cat:" + part + "+OR+"
                }
            }
            
            if query != "" {
                query = query[..<query.index(query.endIndex, offsetBy: -4)] + "+AND+"
            }
            
            
            let api = URL(string: "https://export.arxiv.org/api/query?search_query=\(query)lastUpdatedDate:[\(start)+TO+\(end)]&sortBy=lastUpdatedDate&max_results=800")
            print(api)
            let parser = FeedParser(URL: api!)
            
            parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { (result) in
                self.feed = result.atomFeed
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.indicatortoTitle()
                    self.tableView.scroll(to: .top, animated: true)
                }
                
            }
        } else {
            indicatortoTitle()
            self.tableView.scroll(to: .top, animated: true)
        }
    }
    
    func getDatePair(delta: Int) -> (String, String) {
        return ("\(convertDate(delta: delta))2000", "\(convertDate(delta: delta + 1))1959")
    }
    
    func convertDate(delta: Int) -> String {
        let date = Date()
        let adjusted = Calendar.current.date(byAdding: .day, value: delta - 1, to: date)
        let calendar = Calendar.current
        let year = String(format: "%02d", calendar.component(.year, from: adjusted!))
        let month = String(format: "%02d", calendar.component(.month, from: adjusted!))
        let day = String(format: "%02d", calendar.component(.day, from: adjusted!))
        
        return "\(year)\(month)\(day)"
    }
    
    func displayDate(delta: Int) -> String {
        let date = Date()
        let adjusted = Calendar.current.date(byAdding: .day, value: delta, to: date)!
        let adjusted2 = Calendar.current.date(byAdding: .day, value: delta + 1, to: date)!
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MMM-yyyy"
        
        return "\(formatter.string(from: adjusted)) - \(formatter.string(from: adjusted2))"
    }
    
    func prevDay(delta: Int) -> Int {
        let date = Date()
        let adjusted = Calendar.current.date(byAdding: .day, value: delta + 1, to: date)
        let calendar = Calendar.current
        let adjustment = [-3, -3, -1, -1, -1, -1, -2]
        print(adjustment[calendar.component(.weekday, from: adjusted!) - 1])
        
        return delta + adjustment[calendar.component(.weekday, from: adjusted!) - 1]
    }
    
    func nextDay(delta: Int) -> Int {
        let date = Date()
        let adjusted = Calendar.current.date(byAdding: .day, value: delta + 1, to: date)
        let calendar = Calendar.current
        let adjustment = [1, 1, 1, 1, 1, 3, 2]
        
        return delta + adjustment[calendar.component(.weekday, from: adjusted!) - 1]
    }
    
    func titletoIndicator() {
        self.navigationItem.titleView = indicator
        indicator.startAnimating()
    }
    
    func indicatortoTitle() {
        indicator.stopAnimating()
        self.navigationItem.titleView = self.titleView
    }

    @IBAction func progressDate(_ sender: Any) {
        print(dateDelta, nextDay(delta: dateDelta))
        if nextDay(delta: dateDelta) < -1 {
            dateDelta = nextDay(delta: dateDelta)
            let (start, end) = getDatePair(delta: dateDelta)
            titleButton.setTitle(displayDate(delta: dateDelta), for: .normal)
            updateSubscriptions(start: start, end: end)
        }
    }
    
    @IBAction func regressDate(_ sender: Any) {
        dateDelta = prevDay(delta: dateDelta)
        let (start, end) = getDatePair(delta: dateDelta)
        titleButton.setTitle(displayDate(delta: dateDelta), for: .normal)
        updateSubscriptions(start: start, end: end)
    }
    
    @objc func refresh() {
        let (start, end) = getDatePair(delta: dateDelta)
        updateSubscriptions(start: start, end: end)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let dest = segue.destination as? ArticleViewController {
            dest.article = selectedArticle
        } else if segue.identifier == "viewCalendar" {
            // Center the popover
            let controller = segue.destination.popoverPresentationController
            let rect = controller?.sourceRect
            print(rect)
            controller?.sourceRect = CGRect(x: (self.navigationItem.titleView?.bounds.width)! / 2, y: (self.navigationItem.titleView?.bounds.height)!, width: rect!.width, height: rect!.height)
            controller?.delegate = self
            
            let dest = segue.destination as! CalendarViewController
            dest.callback = { result in
                self.dateDelta = result
                let (start, end) = self.getDatePair(delta: self.dateDelta)
                self.titleButton.setTitle(self.displayDate(delta: self.dateDelta), for: .normal)
                self.updateSubscriptions(start: start, end: end)
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let (start, end) = getDatePair(delta: dateDelta)
        updateSubscriptions(start: start, end: end)
    }

}

extension MainTableViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
