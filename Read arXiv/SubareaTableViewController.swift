//
//  SubareaTableViewController.swift
//  arXiv Reader
//
//  Created by Frederick Morlock on 7/19/19.
//  Copyright © 2019 Frederick Morlock. All rights reserved.
//

import UIKit

class SubareaTableViewController: UITableViewController {
    var area: Area?
    var defaults: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.navigationItem.title = area?.name
        let subscriptions = UserDefaults.standard.dictionary(forKey: "subscriptions")
        defaults = (subscriptions?[area!.code] ?? []) as! [String]
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if area == nil {
            return 0
        }
        
        return (area?.subareas?.count ?? 0) + 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "All " + area!.name
            if defaults.contains(area!.code) {
                cell.accessoryType = .checkmark
            }
        } else {
            cell.textLabel?.text = area!.subareas![indexPath.row - 1].name
            if defaults.contains(area!.subareas![indexPath.row - 1].code) {
                cell.accessoryType = .checkmark
            }
        }

        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath)
        
        if cell?.accessoryType == .checkmark {
            cell?.accessoryType = .none
        } else {
            cell?.accessoryType = .checkmark
        }
        
        var item: String
        if indexPath.row == 0 {
            item = area!.code
        } else {
            item = area!.subareas![indexPath.row - 1].code
        }
        
        guard let index = defaults.firstIndex(of: item) else {
            var cleared = false
            if item == area!.code || (defaults.count > 0 && defaults[0] == area!.code) {
                defaults.removeAll()
                cleared = true
            }
            
            defaults.append(item)
            setSubscriptions()
            
            if cleared {
                self.tableView.reloadData()
            }
            
            return
        }
        
        defaults.remove(at: index)
        setSubscriptions()
    }
    
    func setSubscriptions() {
        var subscriptions = UserDefaults.standard.dictionary(forKey: "subscriptions") ?? [:]
        subscriptions[area!.code] = defaults
        UserDefaults.standard.set(subscriptions, forKey: "subscriptions")
    }
 

}
