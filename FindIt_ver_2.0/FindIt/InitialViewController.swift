//
//  InitialViewController.swift
//  FindIt
//
//  Created by Mona Ramesh on 4/17/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import AVFoundation

class InitialViewController: UIViewController, AVSpeechSynthesizerDelegate{
    
    @IBOutlet var getStartedButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getStartedButton.hidden = true

        // AVFoundation framework - Text to Speech implementation
        let synth = AVSpeechSynthesizer()
        synth.delegate = self;
        var myUtterance = AVSpeechUtterance(string: "")
        let speak = "Welcome to Find it. A guide to your neighborhood. Tap on get started."
        myUtterance = AVSpeechUtterance(string: speak)
        myUtterance.rate = 0.5
        synth.speakUtterance(myUtterance)
    }
    
    // Waiting for the speech to be completed
    func speechSynthesizer(synth: AVSpeechSynthesizer, didFinishSpeechUtterance myUtterance: AVSpeechUtterance) {
        getStartedButton.hidden = false
    }
    
}

