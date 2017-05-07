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
        
        let locateX = Locale(identifier: "vi_VN")
        var cal = Calendar.current
        cal.locale = locateX
        datePicker.calendar = cal
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(ViewController.onDatePickerChanged(_:)), for: .valueChanged)
        lunarDatePicker.showYearName = false
        lunarDatePicker.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onDatePickerChanged(_ sender: UIDatePicker) {
        lunarDatePicker.setGRDate(sender.date)
    }

    func onLunarDateChanged(_ date: Date) {
        datePicker.setDate(date, animated: true)
    }
}

