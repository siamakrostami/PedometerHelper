//
//  Int64.swift
//  PedometerHelper
//
//  Created by Siamak Rostami on 8/7/21.
//

import Foundation

extension Int64{
    internal func FormatTime() -> String {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour,.minute, .second]
        return formatter.string(from: TimeInterval(self)) ?? "00:00:00"
        
        
    }
    
    func calculateTime() -> String {
        var min = "\(self / 60)"
        var sec = "\(self % 60)"
        if min.count == 1 {
            min = "0"+min
        }
        if sec.count == 1 {
            sec = "0"+sec
        }
        return "\(min):\(sec)"
    }
    
    
}
