//
//  CalendarViewController.swift
//  Read arXiv
//
//  Created by Frederick Morlock on 8/22/19.
//  Copyright © 2019 Frederick Morlock. All rights reserved.
//

import UIKit
import FSCalendar

class CalendarViewController: UIViewController, FSCalendarDelegate {
    @IBOutlet weak var calendar: FSCalendar!
    
    var callback : ((Int)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        calendar.delegate = self
    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.component(.weekday, from: date)
        let mdate = Date()
        let dayBarrier = Calendar.current.date(byAdding: .day, value: -2, to: mdate)
        if components == 6 || components == 7 || date > dayBarrier! {
            cell.isUserInteractionEnabled = false
            cell.titleLabel.textColor = .lightGray
        }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        callback!(Calendar.current.dateComponents([.day], from: Date(), to: date).day!)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
