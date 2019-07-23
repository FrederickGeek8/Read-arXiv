//
//  ViewController.swift
//  arXiv Reader
//
//  Created by Frederick Morlock on 7/18/19.
//  Copyright © 2019 Frederick Morlock. All rights reserved.
//

import UIKit

struct Area: Codable {
    var code: String
    var name: String
    var subareas: [Area]?
}

struct Subject: Codable {
    var name: String
    var areas: [Area]
}

class SubscriptionViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var subjects: [Subject] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        guard let path = Bundle.main.path(forResource: "subjects", ofType: "json") else { return }
        let url = URL(fileURLWithPath: path)
        
        do {
            let contents = try Data(contentsOf: url)
            subjects = try JSONDecoder().decode([Subject].self, from: contents)
        } catch let error {
            print("Error", error)
            return
        }
        
        self.navigationItem.title = "Subscriptions"
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
}

extension SubscriptionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let view = SubareaTableViewController(style: .plain)
        view.area = subjects[indexPath.section].areas[indexPath.row]
        self.navigationController?.pushViewController(view, animated: true)
    }
}

extension SubscriptionViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return subjects.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return subjects[section].name
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subjects[section].areas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "test")
        cell.textLabel?.text = subjects[indexPath.section].areas[indexPath.row].name
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}
