//
//  ViewController.swift
//  MonkeySeeMonkeyDo
//
//  Created by Paula Chojnacki on 6/10/15.
//  Copyright (c) 2015 Paula, Brian, Shain. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    let pedometer: CMPedometer = CMPedometer()
    let manager = CMMotionManager()
    let queue = NSOperationQueue.mainQueue()
    
    var startTime = NSDate()
    var stopTime = NSDate()
    var selected = String()
    var randInt = Int()
    var passedGyro = Bool()
    var accCount = Int()
    var passedTurn = Int()
    var score = 0
    var answeredQuestion = false
    var seconds = 60
    var timer = NSTimer()
    
    var actions = ["Take 10 steps", "Spin in a circle", "Raise your hand quickly 5 times", "Turn towards your right"]
    
    @IBOutlet weak var stepCount: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var nextLabel: UIButton!
    
    @IBAction func resetButtonPressed(sender: UIButton) {
        manager.stopGyroUpdates()
        manager.stopAccelerometerUpdates()
        manager.stopDeviceMotionUpdates()
        randInt = Int(arc4random_uniform(UInt32(actions.count)))
        selected = actions[randInt]
        self.stepCount.text = selected
        if answeredQuestion == false {
            updateScore(-5)
        }
        answeredQuestion = false
        startButton.hidden = false
        stopButton.hidden = true
    }
    @IBAction func startButtonPressed(sender: UIButton) {
        startButton.hidden = true
        stopButton.hidden = false
        passedGyro = false
        if randInt == 0 {
            startTime = NSDate()
        } else if randInt == 1 {
            manager.gyroUpdateInterval = 0.2
            manager.startGyroUpdatesToQueue(queue) {
                (data, error) in
                if abs(Int(data.rotationRate.z)) >= 7 {
                    self.passedGyro = true
                }
            }
        } else if randInt == 2 {
            accCount = 0
            var accPassed = false
            manager.accelerometerUpdateInterval = 0.01
            manager.startAccelerometerUpdatesToQueue(queue) {
                (data, error) in
                if data.acceleration.y > 0.1 && accPassed == false {
                    accPassed = true
                    self.accCount++
                }
                if data.acceleration.y < -0.3 {
                    accPassed = false
                }
            }
        } else {
            passedTurn = 0
            manager.deviceMotionUpdateInterval = 0.1
            manager.startDeviceMotionUpdatesToQueue(queue) {
                (data, error) in
                println(data.attitude.yaw)
                if data.attitude.yaw < -1.5 {
                    self.passedTurn = 1
                }
                if data.attitude.yaw > 1 {
                    self.passedTurn = -1
                }
            }
        }
    }
    
    @IBAction func stopButtonPressed(sender: UIButton) {
        stopButton.hidden = true
        answeredQuestion = true
        if randInt == 0 {
            stopTime = NSDate()
            pedometer.queryPedometerDataFromDate(startTime, toDate: stopTime, withHandler: { data, error in
                var steps = Int(data.numberOfSteps)
                dispatch_async(dispatch_get_main_queue()) {
                    if steps >= 8 && steps <= 12 {
                        self.stepCount.text = "Congratulations, you've met the goal!"
                        self.updateScore(5)
                    } else if steps < 8 {
                        self.stepCount.text = "Sorry, you only took \(steps) steps"
                    } else {
                        self.stepCount.text = "Sorry, you took too many steps"
                    }
                }
            })
        } else if randInt == 1 {
            manager.stopGyroUpdates()
            if self.passedGyro == true {
                stepCount.text = "Congratulations, you've met the goal!"
                updateScore(5)
            } else {
                stepCount.text = "Sorry, please make a full circle for credit"
            }
        } else if randInt == 2 {
            manager.stopAccelerometerUpdates()
            if accCount >= 5 {
                stepCount.text = "Congratulations, you've met the goal!"
                updateScore(5)
            } else {
                stepCount.text = "Sorry, you raised your hand only \(accCount) times"
            }
        } else {
            manager.stopDeviceMotionUpdates()
            if passedTurn == 1 {
                stepCount.text = "Congratulations, you've met the goal!"
                updateScore(5)
            } else if passedTurn == -1 {
                stepCount.text = "Right, not left!"
            } else {
                stepCount.text = "Sorry, you did not turn fully right"
            }
        }
    }
    
    func updateScore(amount: Int)-> () {
        score += amount
        scoreLabel.text = "Score: " + String(score)
    }

    @IBAction func totalReset(sender: UIButton) {
        timer.invalidate()
        score = 0
        scoreLabel.text = "Score: " + String(score)
        randInt = Int(arc4random_uniform(UInt32(actions.count)))
        selected = actions[randInt]
        self.stepCount.text = selected
        startButton.hidden = false
        stopButton.hidden = true
        nextLabel.hidden = false
        seconds = 60
        timerLabel.text = "Time: \(seconds)"
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        randInt = Int(arc4random_uniform(UInt32(actions.count)))
        selected = actions[randInt]
        self.stepCount.text = selected
        startButton.hidden = false
        stopButton.hidden = true
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
    }
    
    func update() {
        seconds--
        timerLabel.text = "Time: \(seconds)"
        
        if seconds < 1 {
            timer.invalidate()
            if score < 15 {
                stepCount.text = "Better luck next time, your score is \(score)"
            } else {
                stepCount.text = "Great Job! Your score is \(score)"
            }
            stopButton.hidden = true
            startButton.hidden = true
            nextLabel.hidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

