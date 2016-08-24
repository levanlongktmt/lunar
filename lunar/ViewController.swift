//
//  ViewController.swift
//  lunar
//
//  Created by Le Van Long on 8/23/16.
//  Copyright © 2016 Le Van Long. All rights reserved.
//

import UIKit

class ViewController: UIViewController, LunarDatePickerDelegate {

    @IBOutlet weak var lunarDatePicker: LunarDatePicker!
    @IBOutlet weak var datePicker: UIDatePicker!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let locateX = NSLocale(localeIdentifier: "vi_VN")
        let cal = NSCalendar.currentCalendar()
        cal.locale = locateX
        datePicker.calendar = cal
        datePicker.datePickerMode = .Date
        datePicker.addTarget(self, action: #selector(ViewController.onDatePickerChanged(_:)), forControlEvents: .ValueChanged)
        
        lunarDatePicker.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onDatePickerChanged(sender: UIDatePicker) {
        lunarDatePicker.setGRDate(sender.date)
    }

    func onLunarDateChanged(date: NSDate) {
        datePicker.setDate(date, animated: true)
    }
}

