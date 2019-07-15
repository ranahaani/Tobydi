////
////  musicPlayer.swift
////  Tobydi
////
////  Created by Muhammad Abdullah on 12/01/2019.
////  Copyright © 2019 Muhammad Abdullah. All rights reserved.
////
//
//import UIKit
//import AVFoundation
//class MusicPlayerController: UIViewController {
//    
//    var av_plyr: AVAudioPlayer = AVAudioPlayer()
//    
//    var origImg_play = UIImage(named: "Play Filled")!
//    
//    var songs_test = ["Battle at the misty valley", "Twilight Poem", "Classical-bwv-bach"]
//    
//    var songNum = 0
//     var player: AVPlayer!
//
//    //Temporary Scrubber and Volume Control
//    //@IBOutlet var volumeOutlet: UISlider!
//    //@IBOutlet var scrubOutlet: UISlider!
//    
////    @IBAction func volumeAction(sender: AnyObject) {
////        av_plyr.volume = volumeOutlet.value
////    }
////    @IBAction func scrubAction(sender: AnyObject) {
////        av_plyr.currentTime = Double(scrubOutlet.value) * av_plyr.duration
////    }
////
//    
//    private func mediaControls_init() {
//        
//        //Create a container for buttons
//        let containerArea = UIView()
//        containerArea.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0)
//        containerArea.layer.borderWidth = 2
//        containerArea.layer.borderColor = UIColor.lightGray.cgColor
//        containerArea.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(containerArea)
//        
//        //Add Rewind, Play, Fast Forward
//        let origImg_rewind = UIImage(named: "Rewind Filled")!
//        let tintedImg_rewind = origImg_rewind.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
//        let rewindButton = UIButton()
//        
//        let tintedImg_play = origImg_play.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
//        let playButton = UIButton()
//        
//        let origImg_fastf = UIImage(named: "Fast Forward Filled")!
//        let tintedImg_fastf = origImg_fastf.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
//        let fastfButton = UIButton()
//        
//        //Set button specifications
//        let tinted_dict = [rewindButton: tintedImg_rewind, playButton: tintedImg_play, fastfButton: tintedImg_fastf]
//        
//        let button_ls = [rewindButton,playButton,fastfButton]
//        
//        for button in button_ls {
//            button.translatesAutoresizingMaskIntoConstraints = false
//            button.setContentHuggingPriority(UILayoutPriority(rawValue: 251), for: .horizontal)
//            button.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 751), for: .horizontal)
//            button.setImage(tinted_dict[button], for: .normal)
//            button.tintColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1)
//        }
//        
//        //Set button actions and add to subviews
//        rewindButton.addTarget(self, action: Selector("pressedRewind:"), for: .touchUpInside)
//        playButton.addTarget(self, action: Selector("pressedPlay:"), for: .touchUpInside)
//        fastfButton.addTarget(self, action: Selector("pressedFastf:"), for: .touchUpInside)
//        
//        containerArea.addSubview(playButton)
//        containerArea.addSubview(rewindButton)
//        containerArea.addSubview(fastfButton)
//        
//        //Add button constraints
//        let containerAreaConstraints: [NSLayoutConstraint] = [
//            containerArea.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            containerArea.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            containerArea.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            containerArea.heightAnchor.constraint(equalToConstant: 70),
//            
//            rewindButton.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -30),
//            playButton.centerXAnchor.constraint(equalTo: containerArea.centerXAnchor),
//            fastfButton.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 30),
//            
//            rewindButton.centerYAnchor.constraint(equalTo: containerArea.centerYAnchor),
//            playButton.centerYAnchor.constraint(equalTo: containerArea.centerYAnchor),
//            fastfButton.centerYAnchor.constraint(equalTo: containerArea.centerYAnchor)
//        ]
//        
//        NSLayoutConstraint.activate(containerAreaConstraints)
//    }
//    
//    func pressedPlay(button: UIButton) {
//        if av_plyr.isPlaying == false {
//            av_plyr.play()
//            
//            origImg_play = UIImage(named: "Pause Filled")!
//            
//            mediaControls_init()
//            
//            print(av_plyr.duration)
//            
//        } else if av_plyr.isPlaying == true {
//            av_plyr.pause()
//            
//            origImg_play = UIImage(named: "Play Filled")!
//            
//            mediaControls_init()
//        }
//    }
//    
//    func pressedFastf(button: UIButton) {
//        songNum = (songNum + 1)%3
//        //print(songNum)
//        
//        if av_plyr.isPlaying == false {
//            avPlyr_init(index: 11)
//            av_plyr.pause()
//        } else if av_plyr.isPlaying == true {
//            avPlyr_init(index: 1)
//            av_plyr.play()
//        }
//        
//    }
//    
//    func pressedRewind(button: UIButton) {
//        if songNum == 0 {
//            songNum += 1
//        }
//        if av_plyr.isPlaying == false {
//            avPlyr_init(index: 11)
//            av_plyr.pause()
//        } else if av_plyr.isPlaying == true {
//            avPlyr_init(index: 1)
//            av_plyr.play()
//        }
//    }
//    
//    func someAction(button: UIButton) {
//        print("some action")
//    }
//    
//    func avPlyr_init(index: Int) {
//        
//        self.title = songs_test[songNum]
//        
//        //Create a path to the mp3 player
//        let audioPath = songs_test[index]
//        do {
//            try av_plyr = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath) as URL)
//            
//        } catch {
//            print("error")
//        }
//        dismiss(animated: true, completion: nil)
//        
//        
//         Timer.scheduledTimer(timeInterval: 1, target: self, selector: Selector(("updateScrubSlider")), userInfo: nil, repeats: true)
//        
//    }
//    
////    func updateScrubSlider(){
////        scrubOutlet.value = Float(av_plyr.currentTime/av_plyr.duration)
////
////        //print(scrubOutlet.value)
////
////        if scrubOutlet.value >= 0.99 {
////
////            songNum = (songNum + 1)%3
////            //print(songNum)
////
////            if av_plyr.isPlaying == false {
////                avPlyr_init()
////                av_plyr.pause()
////            } else if av_plyr.isPlaying == true {
////                avPlyr_init()
////                av_plyr.play()
////            }
////
////        }
////    }
////
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        self.mediaControls_init()
//        
//        self.avPlyr_init(index: 2)
//        
//        
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//}
