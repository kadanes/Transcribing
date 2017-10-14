//
//  ViewController.swift
//  liveSpeech
//
//  Created by Parth Tamane on 14/10/17.
//  Copyright © 2017 Parth Tamane. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController {
    
    @IBOutlet weak var textDisplay: UITextView!
    
    let audioEngine = AVAudioEngine()
    let recognizer = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognizationTask: SFSpeechRecognitionTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            switch authStatus {
            case .authorized:
                print("Authorized")
            case .denied:
                print("I can't recognize as you denied me access!")
            case .restricted:
                print("Not avilable to recognize")
            case .notDetermined:
                print("Status not determined")
            }
        }
    }

   
    func startTranscription() throws {
        print("Transcribing")
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            
            self.request.append(buffer)
        }
        
        
        audioEngine.prepare()
        
        try audioEngine.start()
        
        recognizationTask =  recognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
            
                
                if let error = error {
                    
                    print("---------------------------------------\n\(error)\n---------------------------------------")
                    
                } else {
                    
                    self.textDisplay.text =  result?.bestTranscription.formattedString
                }
        })
    }

    
    
    @IBAction func stopTranscribing(_ sender: Any) {
        print("Released")

        // When you release, you're finishing, not cancelling.
        recognizationTask?.finish()
        request.endAudio()
        audioEngine.stop()
        // Need to remove the installTap or you will crash on a second record.
        audioEngine.inputNode.removeTap(onBus: 0)
        

    }
    
    @IBAction func startTrascribing(_ sender: Any) {
        
        print("Pressed")
        do {
            
            try startTranscription()
            
        } catch {
            print("Error at the end")
        }
        
    }
    
}

