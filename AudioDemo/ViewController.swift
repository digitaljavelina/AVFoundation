//
//  ViewController.swift
//  AudioDemo
//
//  Created by Simon Ng on 21/11/14.
//  Copyright (c) 2014 AppCoda. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    @IBOutlet weak var playButton:UIButton!
    @IBOutlet weak var stopButton:UIButton!
    @IBOutlet weak var recordButton:UIButton!
    
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // disable stop/play buttons when application launches
        
        stopButton.enabled = false
        playButton.enabled = false
        
        // get the document directory. if it fails, skip the rest of the code
        
        guard let directoryURL = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).first else {
            let alertMessage = UIAlertController(title: "Error", message: "Failed to get the document directory for recording the audio. Please try again later.", preferredStyle: .Alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            
            return
        }
        
        // set the default audio file
        
        let audioFileURL = directoryURL.URLByAppendingPathComponent("MyAudioMemo.m4a")
        
        // set up audio session
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions: AVAudioSessionCategoryOptions.DefaultToSpeaker)
            
            // define the recorder setting
            
            let recorderSetting: [String: AnyObject] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue]
            
            // initiate and prepare the recorder
            
            audioRecorder = try AVAudioRecorder(URL: audioFileURL, settings: recorderSetting)
            audioRecorder?.delegate = self
            audioRecorder?.meteringEnabled = true
            audioRecorder?.prepareToRecord()
        } catch {
            print(error)
        }

    }

    @IBAction func play(sender: AnyObject) {
        if let recorder = audioRecorder {
            if !recorder.recording {
                do {
                    audioPlayer = try AVAudioPlayer(contentsOfURL: recorder.url)
                    audioPlayer?.delegate = self
                    audioPlayer?.play()
                    playButton.setImage(UIImage(named: "playing"), forState: .Selected)
                    playButton.selected = true
                } catch {
                    print(error)
                }
                
            }
        }
    }
    
    @IBAction func stop(sender: AnyObject) {
        recordButton.setImage(UIImage(named: "record"), forState: .Normal)
        recordButton.selected = false
        playButton.setImage(UIImage(named: "play"), forState: .Normal)
        playButton.selected = false
        
        stopButton.enabled = false
        playButton.enabled = true
        
        audioRecorder?.stop()
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
        } catch {
            print(error)
        }
    }
    
    @IBAction func record(sender: AnyObject) {
        // stop the audio player before recording
        
        if let player = audioPlayer {
            if player.playing {
                player.stop()
                playButton.setImage(UIImage(named: "play"), forState: .Normal)
                playButton.selected = false
            }
        }
        
        if let recorder = audioRecorder {
            if !recorder.recording {
                let audioSession = AVAudioSession.sharedInstance()
                
                do {
                    try audioSession.setActive(true)
                    
                    // start recording
                    
                    recorder.record()
                    recordButton.setImage(UIImage(named: "recording"), forState: .Selected)
                    recordButton.selected = true
                } catch {
                    print(error)
                }
            } else {
                // pause recording
                
                recorder.pause()
                recordButton.setImage(UIImage(named: "pause"), forState: .Normal)
                recordButton.selected = false
            }
        }
        
        stopButton.enabled = true
        playButton.enabled = false
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            let alertMessage = UIAlertController(title: "Finish recording", message: "Successfully recorded the audio.", preferredStyle: .Alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        }
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        playButton.setImage(UIImage(named: "play"), forState: .Normal)
        playButton.selected = false
        
        let alertMessage = UIAlertController(title: "Finish playing", message: "Finish playing the recording", preferredStyle: .Alert)
        alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
    }
    
}

