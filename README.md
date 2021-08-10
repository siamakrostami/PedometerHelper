# PedometerHelper

## Description
A simple pedometer app that written in Swift 5 and mvvm architecture

## Usage
This is a simple pedometer code that allows you to fetch CoreMotion datas directly from sensors.
let's start with creating an instance of view model : 

```ruby
let pedometer = Pedometer(weight: 85, gender: .male)
pedometer.delegate = self
```

or 

```ruby
let pedometer = Pedometer()
pedometer.delegate = self
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
        self.pedometer.initializeTimer()
        self.pedometer.getPedometerData(starts: Date()) { data, error in
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
        self.pedometer.currentPedometerActicityStatus { data in
            self.setActivityStatus(currentStatus: data)
        }
    }
    
    fileprivate func setActivityStatus(currentStatus : CurrentActivityStatus){
        DispatchQueue.main.async {
            self.activityStatusLabel.text = currentStatus.rawValue
        }
    }
    
```
calculate burned calories:

```ruby

 fileprivate func getCalories()
    self.pedometer.calculateBurnedCalories { calories in
          DispatchQueue.main.async {
                if calories.isNaN{
                    self.burnedCaloriesLabel.text = "\(0.0)"
                }else{
                    self.burnedCaloriesLabel.text = "\(calories)"
                }
            }
        }
    }
    
```

Stop Pedometer Calculation:

```ruby

  fileprivate func stopPedometer(){
      self.pedometer.stopPedometer()
    }
    
```

How to use:

```ruby

var isStarted : Bool = false

  @IBAction func startPedometer(_ sender: Any) {
        if self.isStarted{
            self.isStarted = false
            self.stopPedometer()
            self.startButton.setTitle("Start", for: .normal)
            self.startButton.backgroundColor = .systemBlue
        }else{
            self.isStarted = true
            self.startPedometer()
            self.getActivityStatus()
            self.startButton.setTitle("Stop", for: .normal)
            self.startButton.backgroundColor = .systemPink
        }
    }
    
```

## Delegation

get current duration:

```ruby

extension YourPedometerViewController : DurationProtocol{
    func currentDuration(duration: Int64) {
        DispatchQueue.main.async {
            self.durationLabel.text = duration.FormatTime()
        }
    } 
}

```

## Example

You can clone the repo and run the app

## License

PedometerHelper is available under the MIT license. See the LICENSE file for more info.



