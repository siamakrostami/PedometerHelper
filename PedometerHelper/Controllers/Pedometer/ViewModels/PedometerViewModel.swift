//
//  PedometerViewModel.swift
//  PedometerHelper
//
//  Created by Siamak Rostami on 8/7/21.
//

import Foundation
import CoreMotion

typealias ActivityStatus = ((CMMotionActivity?) -> Void)
typealias PedometerData = ((CMPedometerData?,Error?) -> Void)
typealias PedometerEventData = ((CMPedometerEvent?,Error?) -> Void)
typealias CalclateBurnedCalories = ((Double) -> Void)

@objc protocol PedometerProtocols {
    func currentPedometerActicityStatus(completion:@escaping ActivityStatus)
    @objc optional func getPedometerData(starts at : Date , completion:@escaping PedometerData)
    @objc optional func getPedometerDataHistory(from : Date , to : Date , completion:@escaping PedometerData)
    @objc optional func getPedometerEventData(completion:@escaping PedometerEventData)
    @objc optional func calculateBurnedCalories(completion:@escaping CalclateBurnedCalories)
    @objc optional func stopPedometer()
    @objc optional func stopPedometerEvents()
}

class PedometerViewModel{
    fileprivate var activityManager = CMMotionActivityManager()
    fileprivate var pedometer = CMPedometer()
    fileprivate var weight : Double?
    fileprivate var gender : gender?
    var currentDuration : Int64?
    fileprivate var steps : Int?
    var pedometerIsStarted : Bool = false
    
    init(weight : Double? = nil , gender : gender? = nil) {
        self.weight = weight
        self.gender = gender
    }
}

extension PedometerViewModel : PedometerProtocols{
    
    func currentPedometerActicityStatus(completion: @escaping ActivityStatus) {
        if CMMotionActivityManager.isActivityAvailable(){
            self.activityManager.startActivityUpdates(to: .main) { activity in
                completion(activity)
            }
        }else{
            completion(.none)
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
    }
    
    func stopPedometerEvents() {
        self.pedometer.stopEventUpdates()
    }
    
    func calculateBurnedCalories(completion: @escaping CalclateBurnedCalories) {
        guard self.currentDuration != nil , self.gender != nil , self.weight != nil else{
            completion(0)
            return
        }
        let minute = (self.currentDuration ?? 0) / 60
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

        completion(calorie.rounded())
    
    }
    
    
}

extension PedometerViewModel {
    /// calculate calories by met
    fileprivate func calculateCalorieByMet(_ met : Double) -> Double{
        guard let weight = self.weight else{return (met * 3.5 * 80) / 200}
        return (met * 3.5 * Double(weight)) / 200
    }
}
