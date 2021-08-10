//
//  PedometerViewModel.swift
//  PedometerHelper
//
//  Created by Siamak Rostami on 8/7/21.
//

import Foundation
import CoreMotion

typealias ActivityStatus = ((CurrentActivityStatus) -> Void)
typealias PedometerData = ((CMPedometerData?,Error?) -> Void)
typealias PedometerEventData = ((CMPedometerEvent?,Error?) -> Void)
typealias CalclateBurnedCalories = ((Double) -> Void)

@objc protocol PedometerProtocols {
    
    @objc optional func getPedometerData(starts at : Date , completion:@escaping PedometerData)
    @objc optional func getPedometerDataHistory(from : Date , to : Date , completion:@escaping PedometerData)
    @objc optional func getPedometerEventData(completion:@escaping PedometerEventData)
    @objc optional func calculateBurnedCalories(completion:@escaping CalclateBurnedCalories)
    @objc optional func stopPedometer()
    @objc optional func stopPedometerEvents()
}

protocol DurationProtocol {
    func currentDuration(duration : Int64)
}

protocol ActivityProtocol {
    func currentPedometerActicityStatus(completion:@escaping ActivityStatus)
}



class Pedometer {
    fileprivate var activityManager = CMMotionActivityManager()
    fileprivate var pedometer = CMPedometer()
    fileprivate var weight : Double?
    fileprivate var gender : gender?
    fileprivate var steps : Int?
    fileprivate var timer : Timer!
    fileprivate var duration : Int64?
    fileprivate var calory : Double?
    var delegate : DurationProtocol!
    
    init(weight : Double? = nil , gender : gender? = nil) {
        self.weight = weight
        self.gender = gender
    }
}

extension Pedometer : PedometerProtocols , ActivityProtocol {
    
    func currentPedometerActicityStatus(completion: @escaping ActivityStatus) {
        if CMMotionActivityManager.isActivityAvailable(){
            self.activityManager.startActivityUpdates(to: .main) { activity in
                guard let activity = activity else{
                    completion(.unknown)
                    return
                }
                if activity.stationary{
                    completion(.stationary)
                }
                if activity.automotive{
                    completion(.automotive)
                }
                if activity.running{
                    completion(.running)
                }
                if activity.cycling{
                    completion(.cycling)
                }
                if activity.walking{
                    completion(.walking)
                }
                if activity.unknown{
                    completion(.unknown)
                }
            }
        }else{
            completion(.unknown)
        }
    }
    
    func getPedometerData(starts at: Date, completion: @escaping PedometerData) {
        if CMPedometer.isStepCountingAvailable(){
            self.pedometer.startUpdates(from: at) { data, error in
                if error == nil{
                    self.steps = data?.numberOfSteps.intValue
                    completion(data,nil)
                }else{
                    completion(nil,error)
                }
            }
        }else{
            completion(nil,nil)
        }
    }
    
    func getPedometerEventData(completion: @escaping PedometerEventData) {
        if CMPedometer.isStepCountingAvailable(){
            self.pedometer.startEventUpdates { data, error in
                if error == nil{
                    completion(data,nil)
                }else{
                   completion(nil,error)
                }
            }
        }else{
            completion(nil,nil)
        }
    }
    
    func getPedometerDataHistory(from: Date, to: Date, completion: @escaping PedometerData) {
        if CMPedometer.isStepCountingAvailable(){
            self.pedometer.queryPedometerData(from: from, to: to) { data, error in
                if error == nil{
                    self.steps = data?.numberOfSteps.intValue
                    completion(data,nil)
                }else{
                    completion(nil,error)
                }
            }
        }else{
            completion(nil,nil)
        }
    }
    
    func stopPedometer() {
        self.pedometer.stopUpdates()
        self.deinitTimer()
    }
    
    func stopPedometerEvents() {
        self.pedometer.stopEventUpdates()
        self.deinitTimer()
    }
    
    func calculateBurnedCalories(completion: @escaping CalclateBurnedCalories) {
        completion(self.calory ?? 0.0)
    }
    
    
}

extension Pedometer {
    
    func initializeTimer(){
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer(){
        if self.duration == nil{
            self.duration = Int64()
        }
        self.duration! += 1
        self.calory = self.currentCalories()
        self.delegate.currentDuration(duration: self.duration ?? 0)
    }
    
    fileprivate func currentCalories() -> Double?{
        guard self.duration != nil , self.gender != nil , self.weight != nil else{
            return 0.0
        }
        let minute = (self.duration ?? 0) / 60
        var MenMet = Double()
        var WomenMet = Double()
        var calorie = Double()
        switch self.gender{
        case .male:
            MenMet = CaloriesStaticDefaults.menMetDefaultValue + (0.105 * Double(self.steps ?? 0) / Double(minute))
            calorie = calculateCalorieByMet(MenMet)
            break
        default:
            WomenMet = CaloriesStaticDefaults.womenMetDefaultValue + (0.110 * Double(self.steps ?? 0) / Double(minute))
            calorie = calculateCalorieByMet(WomenMet)
            break
        }

        return calorie.rounded()
    }
    
    fileprivate func deinitTimer(){
        if timer != nil{
            self.timer.invalidate()
            self.timer = nil
            self.steps = nil
            self.duration = nil
            self.calory = nil
        }
    }
    /// calculate calories by met
    fileprivate func calculateCalorieByMet(_ met : Double) -> Double{
        guard let weight = self.weight else{return (met * 3.5 * 80) / 200}
        return (met * 3.5 * Double(weight)) / 200
    }
}
