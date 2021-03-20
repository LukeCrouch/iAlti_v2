//
//  Variometer.swift
//  iAlti_v2 WatchKit Extension
//
//  Created by Lukas Wheldon on 20.03.21.
//

import Foundation
import AVFoundation

let ClimbToneOnThreshold = 0.1
let ClimbToneOffThreshold = 0.05
let SinkToneOnThreshold = -0.7
let SinkToneOffThreshold = -0.6
let frequency:Float = 500 + Float(Altimeter.shared.glideRatio) * 50
let amplitude:Float = 1
var duration:Float = 0.6 - 0.04 * Float(Altimeter.shared.glideRatio)

let engine = AVAudioEngine()
let mainMixer = engine.mainMixerNode
let output = engine.outputNode
let outputFormat = output.inputFormat(forBus: 0)
let inputFormat = AVAudioFormat(commonFormat: outputFormat.commonFormat,
                                sampleRate: outputFormat.sampleRate,
                                channels: 1,
                                interleaved: outputFormat.isInterleaved)
let sampleRate = Float(outputFormat.sampleRate)
let twoPi = 2 * Float.pi
var currentPhase: Float = 0
let phaseIncrement = (twoPi / sampleRate) * frequency

let srcNode = AVAudioSourceNode { _, _, frameCount, audioBufferList -> OSStatus in
    let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
    for frame in 0..<Int(frameCount) {
        // Get signal value for this frame at time.
        let value = currentPhase * amplitude
        // Advance the phase for the next frame.
        currentPhase += phaseIncrement
        if currentPhase >= twoPi {
            currentPhase -= twoPi
        }
        if currentPhase < 0.0 {
            currentPhase += twoPi
        }
        // Set the same value on all channels (due to the inputFormat we have only 1 channel though).
        for buffer in ablPointer {
            let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
            buf[frame] = value
        }
    }
    return noErr
}

public func playVario() {
    
    engine.attach(srcNode)
    engine.connect(srcNode, to: mainMixer, format: inputFormat)
    engine.connect(mainMixer, to: output, format: outputFormat)
    do {
        repeat {
            if Altimeter.shared.glideRatio > ClimbToneOnThreshold || Altimeter.shared.glideRatio < SinkToneOnThreshold {
                mainMixer.outputVolume = 1
            } else if Altimeter.shared.glideRatio < ClimbToneOffThreshold && Altimeter.shared.glideRatio > SinkToneOffThreshold {
                mainMixer.outputVolume = 0
            }
            try engine.start()
            CFRunLoopRunInMode(.defaultMode, CFTimeInterval(duration), false)
            engine.stop()
            sleep(UInt32(duration))
        } while LocationManager.shared.didLand == false && LocationManager.shared.didTakeOff == true
    } catch {
        print("Could not start AVAudioEngine: \(error)")
    }
}

public func playAudio() {
    if UserSettings.shared.voiceOutputSelection == 0 {
        return
    } else if UserSettings.shared.voiceOutputSelection == 5 {
        playVario()
    } else {
        voiceOutput()
    }
}
