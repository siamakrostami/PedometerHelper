# PedometerHelper

## Description
A simple pedometer app that written in Swift 5 and mvvm architecture

## Usage
This is a simple pedometer code that allows you to fetch CoreMotion datas directly from sensors.
let's start with creating an instance of view model : 

```ruby
let pedometerViewModel = PedometerViewModel(weight: 85, gender: .male)
```

or 

```ruby
let pedometerViewModel = PedometerViewModel()
```

if you initialize the viewModel with weight and gender parameters, you can calculate burned calories in your code.

Add NSMotionUsageDescription to info.plist:

```ruby

	<key>NSMotionUsageDescription</key>
	<string>To Collect Pedometer Data</string>
  
```  

Start fetching data from sensor:

```ruby
    fileprivate func startPedometer(){
        self.pedometerViewModel.getPedometerData(starts: Date()) { data, error in
            if error == nil{
                DispatchQueue.main.async {
                    self.YourStepsCountLabel.text = data?.numberOfSteps.stringValue ?? "\(0)"
                }
            }
        }
    }
```
Get activity status:

```ruby
    fileprivate func getActivityStatus(){
        self.pedometerViewModel.currentPedometerActicityStatus { data in
            guard let activity = data else{return}
            self.setActivityStatus(currentStatus: activity)
        }
    }
    
    fileprivate func setActivityStatus(currentStatus : CMMotionActivity){
        DispatchQueue.main.async {
            if currentStatus.stationary{
                self.YourActivityStatusLabel.text = "stationary"
            }
            if currentStatus.automotive{
                self.YourActivityStatusLabel.text = "automotive"
            }
            if currentStatus.running{
                self.YourActivityStatusLabel.text = "running"
            }
            if currentStatus.cycling{
                self.YourActivityStatusLabel.text = "cycling"
            }
            if currentStatus.walking{
                self.YourActivityStatusLabel.text = "walking"
            }
            if currentStatus.unknown{
                self.YourActivityStatusLabel.text = "unknown"
            }
            
        }
    }
```
Initialize timer and calculate burned calories:

```ruby
let timer : Timer!
let time : Int64!
```

```ruby

    fileprivate func initializeTimer(){
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
     @objc func updateTimer(){
        self.time += 1
        self.pedometerViewModel.currentDuration = self.time
        self.getCalories()
        DispatchQueue.main.async {
            self.YourDurationLabel.text = "\(time)"
        }
    }
    
     fileprivate func getCalories(){
        self.pedometerViewModel.calculateBurnedCalories { calories in
            DispatchQueue.main.async {
                if calories.isNaN{
                    self.YourBurnedCaloriesLabel.text = "\(0.0)"
                }else{
                    self.YourBurnedCaloriesLabel.text = "\(calories)"
                }
            }
        }
    }
```

Stop Pedometer Calculation:

```ruby
    fileprivate func deinitTimer(){
        if timer != nil{
            self.timer.invalidate()
        }
    }
    
     fileprivate func stopPedometer(){
        self.pedometerViewModel.stopPedometer()
        self.deinitTimer()
    }
```

How to use:

```ruby

    @IBAction func startPedometerCalculation(_ sender: Any) {
        if self.pedometerViewModel.pedometerIsStarted{
            self.pedometerViewModel.pedometerIsStarted = false
            self.stopPedometer()
            self.startButton.setTitle("Start", for: .normal)
            self.startButton.backgroundColor = .systemBlue
        }else{
            self.pedometerViewModel.pedometerIsStarted = true
            self.startPedometer()
            self.initializeTimer()
            self.getActivityStatus()
            self.startButton.setTitle("Stop", for: .normal)
            self.startButton.backgroundColor = .systemPink
        }
    }
}
```

## Example

You can clone the repo and run the app

## License

PedometerHelper is available under the MIT license. See the LICENSE file for more info.



