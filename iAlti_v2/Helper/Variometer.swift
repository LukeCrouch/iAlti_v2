//
//  Variometer.swift
//  iAlti_v2
//
//  Created by Lukas Wheldon on 18.03.21.
//

import Foundation
import AVFoundation

class Vario {
    
    typealias Signal = (_ frequency: Float, _ time: Float) -> Float
    
    static let sine: Signal = { frequency, time in
        let amplitude:Float = 1
        return amplitude * sin(2.0 * Float.pi * frequency * time)
    }
    
    // MARK: Properties
    public static let shared = Vario()
    
    private var volume: Float {
        set {
            audioEngine.mainMixerNode.outputVolume = newValue
        }
        get {
            audioEngine.mainMixerNode.outputVolume
        }
    }
    
    private var frequencyRampValue: Float = 0
    
    private var frequency: Float = 440 {
        didSet {
            if oldValue != 0 {
                frequencyRampValue = frequency - oldValue
            } else {
                frequencyRampValue = 0
            }
        }
    }
    
    private var audioEngine: AVAudioEngine
    private lazy var sourceNode = AVAudioSourceNode { _, _, frameCount, audioBufferList in
        let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
        
        let localRampValue = self.frequencyRampValue
        let localFrequency = self.frequency - localRampValue
        
        let period = 1 / localFrequency
        
        for frame in 0..<Int(frameCount) {
            let percentComplete = self.time / period
            let sampleVal = self.signal(localFrequency + localRampValue * percentComplete, self.time)
            self.time += self.deltaTime
            self.time = fmod(self.time, period)
            
            for buffer in ablPointer {
                let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
                buf[frame] = sampleVal
            }
        }
        
        self.frequencyRampValue = 0
        
        return noErr
    }
    
    private var time: Float = 0
    private let sampleRate: Double
    private let deltaTime: Float
    
    private var signal: Signal
    
    // MARK: Init
    init(signal: @escaping Signal = sine) {
        audioEngine = AVAudioEngine()
        
        let mainMixer = audioEngine.mainMixerNode
        let outputNode = audioEngine.outputNode
        let format = outputNode.inputFormat(forBus: 0)
        
        sampleRate = format.sampleRate
        deltaTime = 1 / Float(sampleRate)
        
        self.signal = signal
        
        let inputFormat = AVAudioFormat(commonFormat: format.commonFormat,
                                        sampleRate: format.sampleRate,
                                        channels: 1,
                                        interleaved: format.isInterleaved)
        
        audioEngine.attach(sourceNode)
        audioEngine.connect(sourceNode, to: mainMixer, format: inputFormat)
        audioEngine.connect(mainMixer, to: outputNode, format: nil)
        mainMixer.outputVolume = 1
    }
    
    // MARK: Control
    func playVario(testing: Bool) {
        let ClimbToneOnThreshold = 0.1
        let ClimbToneOffThreshold = 0.05
        let SinkToneOnThreshold = -0.7
        let SinkToneOffThreshold = -0.6
        
        do {
            try audioEngine.start()
        } catch {
            print("Could not start engine: \(error.localizedDescription)")
        }
        
        DispatchQueue.main.async {
            var loopSwitch = false
            var timerVolume = 1.0
            var threshholdVolume = 1.0
            
            repeat {
                if loopSwitch {
                    timerVolume = 0
                } else {
                    timerVolume = 1
                }
                let climbRate = Altimeter.shared.speedVertical
                
                if testing {
                    threshholdVolume = 1
                } else if climbRate > ClimbToneOnThreshold || climbRate < SinkToneOnThreshold {
                    threshholdVolume = 1
                } else if climbRate < ClimbToneOffThreshold && climbRate > SinkToneOffThreshold {
                    threshholdVolume = 0
                }
                
                self.audioEngine.mainMixerNode.outputVolume = Float(timerVolume * threshholdVolume)
                
                self.frequency = 500 + Float(climbRate) * 50
                let waitSeconds = 0.6 - 0.04 * abs(climbRate)
                usleep(UInt32(waitSeconds * 1000000))
                
                print("Vario Timestamps: ", Date(), Altimeter.shared.timestamp)
                
                loopSwitch.toggle()
            } while LocationManager.shared.didLand == false && LocationManager.shared.didTakeOff == true
            sleep(1)
            self.audioEngine.stop()
        }
    }
}
