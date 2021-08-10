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
    
    fileprivate var pedometerViewModel : Pedometer!
    fileprivate var isStarted : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeViewControllerVariables()
        // Do any additional setup after loading the view.
    }
    
    /// start or stop calculation
    @IBAction func startPedometer(_ sender: Any) {
        if self.isStarted{
            self.isStarted = false
            self.stopPedometer()
            self.startOutlet.setTitle("Start", for: .normal)
            self.startOutlet.backgroundColor = .systemBlue
        }else{
            self.isStarted = true
            self.startPedometer()
            self.getActivityStatus()
            self.startOutlet.setTitle("Stop", for: .normal)
            self.startOutlet.backgroundColor = .systemPink
        }
    }
}

extension PedometerViewController{
    
    fileprivate func initializeViewControllerVariables(){
        self.pedometerViewModel = Pedometer(weight: 85, gender: .male)
        self.pedometerViewModel.delegate = self
    }
    
    fileprivate func startPedometer(){
        self.pedometerViewModel.initializeTimer()
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
    }
    
    fileprivate func getActivityStatus(){
        self.pedometerViewModel.currentPedometerActicityStatus { data in
            self.setActivityStatus(currentStatus: data)
        }
    }
    
    fileprivate func setActivityStatus(currentStatus : CurrentActivityStatus){
        DispatchQueue.main.async {
            self.activityStatusLabel.text = currentStatus.rawValue
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
    
    
}

extension PedometerViewController : DurationProtocol{
    func currentDuration(duration: Int64) {
        DispatchQueue.main.async {
            self.durationLabel.text = duration.FormatTime()
        }
    }
    
    
}

