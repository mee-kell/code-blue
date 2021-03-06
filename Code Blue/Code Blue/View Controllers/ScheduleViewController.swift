//
//  ScheduleViewController.swift
//  Code Blue
//
//  Created by Michelle Lo on 28/12/19.
//  Copyright © 2019 Michelle Lo. All rights reserved.
//

import UIKit
import UserNotifications

class ScheduleViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    // For a mixture of different functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Pomodoro timer
        circularProgressView.angle = 0
        stopButton.isEnabled = false
        
        // Important task picker
        self.picker?.delegate = self
        self.picker?.dataSource = self
        pickerData = ["Coursework", "Internal Assessment", "Extended Essay", "Language Oral", "Update ManageBac", "CAS Project"]
    }
    
// POMODORO TIMER
    
    @IBOutlet weak var circularProgressView: KDCircularProgress!
    
    @IBOutlet var timerLabel: UILabel!
    
    // Settings for 25 minutes
    var seconds = 1500
    var timer = Timer()
    var isTimerRunning = false
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(ScheduleViewController.updateTimer)), userInfo: nil, repeats: true)
        isTimerRunning = true
        stopButton.isEnabled = true
    }
    
    func startProgress() {
        circularProgressView.animate(fromAngle: 0, toAngle: 360, duration: 1500, completion: nil)
    }
    
    @objc func updateTimer() {
        if seconds < 1 {
            timer.invalidate()
                // Pop up notification when time is up
                let successAlert = UIAlertController(title: "Time's up!", message: "Take a 5 minute break before coming back.", preferredStyle: .alert)
                successAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(successAlert, animated: true)
        } else {
            seconds -= 1
            timerLabel.text = timeString(time: TimeInterval(seconds))
        }
    }
    
    // Display countdown on label
    func timeString(time:TimeInterval) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02i:%02i", minutes, seconds)
    }
    
    // Start button
    @IBOutlet var startButton: UIButton!

    @IBAction func startButtonTapped(_ sender: UIButton) {
        if isTimerRunning == false {
            runTimer()
            startProgress()
            self.startButton.isEnabled = false
        }
    }
    
    // Stop button
    @IBOutlet var stopButton: UIButton!
    
    @IBAction func stopButtonTapped(_ sender: UIButton) {
        timer.invalidate()
        seconds = 1500
        timerLabel.text = timeString(time: TimeInterval(seconds))
        isTimerRunning = false
        startButton.isEnabled = true
    }

    
// IMPORTANT TASK PICKER
    
    @IBOutlet var picker: UIPickerView!
    
    @IBOutlet weak var setDate: UIDatePicker!
    
    var pickerData : [String] = [String]()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Number of columns
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Number of rows
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    /*
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
    } */

    
    
    // Function to add notification alarm
    func scheduleNotification(message: String) {
        
        let center = UNUserNotificationCenter.current()
        
        // Ask for permission
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Yay!")
            } else {
                print("D'oh")
            }
        }
        
        // Settings for notification alarm
        let content = UNMutableNotificationContent()
        content.title = "Code Blue Reminder"
        content.body = message
        content.categoryIdentifier = "alarm"
        content.sound = UNNotificationSound.default
        
        // Choosing a date
        var dateComponents = DateComponents()
        
        let components = setDate.calendar.dateComponents([.day, .month, .year],from: setDate.date)
        dateComponents.day = components.day
        dateComponents.month = components.month
        dateComponents.year = components.year
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // Create and register notification request
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
            if error != nil {
                let uhOh = UIAlertController(title: "Sorry!", message: "Please enable notifications.", preferredStyle: .alert)
                
                uhOh.addAction(UIAlertAction(title: "Try again", style: .default, handler: nil))
                
                self.present(uhOh, animated: true)
            }
        }
        
    }
    
    // Add notification alarm when switch is turned on
    var isSwitchOn = false
    
    @IBAction func switchTappedOn(_ sender: UISwitch) {
        if !isSwitchOn {
            let picked = pickerData[picker.selectedRow(inComponent: 0)]
            scheduleNotification(message: picked)
            isSwitchOn = true
            
            let alert = UIAlertController(title: "Done!", message: "A notification will appear when your task is due.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            
        }
    }
    
    
}
