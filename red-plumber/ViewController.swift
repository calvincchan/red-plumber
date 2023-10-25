//
//  ViewController.swift
//  red-plumber
//
//  Created by Calvin on 2023-10-25.
//

import UIKit
import AVFoundation
import CoreMotion

class ViewController: UIViewController {
  
  let motionManager = CMMotionManager()
  var soundEffectPlayers: [AVAudioPlayer] = []
  var cleanupTimer: Timer?

  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // Check if the accelerometer is available
    if motionManager.isAccelerometerAvailable {
      // Start accelerometer updates
      motionManager.accelerometerUpdateInterval = 0.01
      motionManager.startAccelerometerUpdates(to: .main) { (data, error) in
        if let acceleration = data?.acceleration {
          let z = acceleration.z
          
          // Calculate the magnitude of acceleration
          let accelerationMagnitude = abs(z)
          
          let threshold: Double = 1.5 // Adjust this value as needed
          
          if accelerationMagnitude > threshold {
            // A sudden jolt was detected
            self.playSoundEffect()
          }
        }
      }
    } else {
      print("Accelerometer is not available on this device.")
    }
    
    // Start the cleanup timer
    startCleanupTimer()
  }
  
  func playSoundEffect() {
    if let soundURL = Bundle.main.url(forResource: "super-mario-bros-coin", withExtension: "mp3") {
      do {
        let player = try AVAudioPlayer(contentsOf: soundURL)
        player.prepareToPlay()
        player.play()
        soundEffectPlayers.append(player)
      } catch {
        print("Error loading sound effect: \(error)")
      }
    }
  }

  @objc func cleanupSoundEffects() {
    soundEffectPlayers = soundEffectPlayers.filter { !$0.isPlaying }
  }
  
  func startCleanupTimer() {
    cleanupTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(cleanupSoundEffects), userInfo: nil, repeats: true)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    // Stop accelerometer updates and invalidate the cleanup timer
    motionManager.stopAccelerometerUpdates()
    cleanupTimer?.invalidate()
    cleanupTimer = nil
  }
  
  deinit {
    motionManager.stopAccelerometerUpdates()
  }
}
