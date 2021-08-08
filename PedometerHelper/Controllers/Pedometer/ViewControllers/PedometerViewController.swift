//
//  ViewController.swift
//  PedometerHelper
//
//  Created by Siamak Rostami on 8/7/21.
//

import UIKit
import CoreMotion

class PedometerViewController: UIViewController {
    
    @IBOutlet weak var activityStatusLabel: UILabel!
    @IBOutlet weak var stepsCountLabel: UILabel!
    @IBOutlet weak var burnedCaloriesLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var startOutlet: UIButton!{
        didSet{
            startOutlet.layer.cornerRadius = 16
        }
    }
    
    fileprivate var pedometerViewModel : PedometerViewModel!
    fileprivate var timer : Timer!
    fileprivate var time = Int64()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeViewControllerVariables()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func startPedometer(_ sender: Any) {
        if self.pedometerViewModel.pedometerIsStarted{
            self.pedometerViewModel.pedometerIsStarted = false
            self.stopPedometer()
            self.startOutlet.setTitle("Start", for: .normal)
            self.startOutlet.backgroundColor = .systemBlue
        }else{
            self.pedometerViewModel.pedometerIsStarted = true
            self.startPedometer()
            self.initializeTimer()
            self.getActivityStatus()
            self.startOutlet.setTitle("Stop", for: .normal)
            self.startOutlet.backgroundColor = .systemPink
        }
    }
    
}

extension PedometerViewController{
    
    fileprivate func initializeViewControllerVariables(){
        self.pedometerViewModel = PedometerViewModel(weight: 85, gender: .male)
    }
    
    @objc func updateTimer(){
        self.time += 1
        self.pedometerViewModel.currentDuration = self.time
        self.getCalories()
        DispatchQueue.main.async {
            self.durationLabel.text = self.time.FormatTime()
        }
    }
    
    fileprivate func startPedometer(){
        self.pedometerViewModel.getPedometerData(starts: Date()) { data, error in
            if error == nil{
                DispatchQueue.main.async {
                    self.stepsCountLabel.text = data?.numberOfSteps.stringValue ?? "\(0)"
                }
            }
        }
    }
    
    fileprivate func stopPedometer(){
        self.pedometerViewModel.stopPedometer()
        self.deinitTimer()
    }
    
    fileprivate func getActivityStatus(){
        self.pedometerViewModel.currentPedometerActicityStatus { data in
            guard let activity = data else{return}
            self.setActivityStatus(currentStatus: activity)
        }
    }
    
    fileprivate func setActivityStatus(currentStatus : CMMotionActivity){
        DispatchQueue.main.async {
            if currentStatus.stationary{
                self.activityStatusLabel.text = "stationary"
            }
            if currentStatus.automotive{
                self.activityStatusLabel.text = "automotive"
            }
            if currentStatus.running{
                self.activityStatusLabel.text = "running"
            }
            if currentStatus.cycling{
                self.activityStatusLabel.text = "cycling"
            }
            if currentStatus.walking{
                self.activityStatusLabel.text = "walking"
            }
            if currentStatus.unknown{
                self.activityStatusLabel.text = "unknown"
            }
            
        }
        
    }
    
    fileprivate func getCalories(){
        self.pedometerViewModel.calculateBurnedCalories { calories in
            DispatchQueue.main.async {
                if calories.isNaN{
                    self.burnedCaloriesLabel.text = "\(0.0)"
                }else{
                    self.burnedCaloriesLabel.text = "\(calories)"
                }
            }
        }
    }
    
    fileprivate func initializeTimer(){
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    fileprivate func deinitTimer(){
        if timer != nil{
            self.timer.invalidate()
        }
    }
    
}

