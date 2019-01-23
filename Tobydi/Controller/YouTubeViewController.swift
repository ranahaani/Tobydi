//
//  ViewController.swift
//  Tobydi
//
//  Created by Muhammad Abdullah on 11/01/2019.
//  Copyright © 2019 Muhammad Abdullah. All rights reserved.
//

import UIKit
import Kingfisher
import AVFoundation
import FRadioPlayer
import YoutubeDirectLinkExtractor
import StreamingKit
import SVProgressHUD
import MarqueeLabel
import GoogleMobileAds
import Reachability
class YouTubeViewController: UIViewController,FRadioPlayerDelegate,UICollectionViewDelegate,UICollectionViewDataSource {
    func radioPlayer(_ player: FRadioPlayer, playerStateDidChange state: FRadioPlayerState) {
        SVProgressHUD.show(UIImage(named: "PauseFilled") ?? UIImage(named:"play-button")!, status: "Paused")
    }
    
    func radioPlayer(_ player: FRadioPlayer, playbackStateDidChange state: FRadioPlaybackState) {
        SVProgressHUD.show(UIImage(named: "PlayFilled") ?? UIImage(named:"play-button")!, status: "Played")
    }
    var bannerView: GADBannerView!

    let player = FRadioPlayer.shared

    let reachability = Reachability()!
    var audioPlayer = STKAudioPlayer()

    @IBOutlet weak var Songtitle: MarqueeLabel!
    @IBOutlet weak var videoView: UIView!
    var rows=0

    var arr:[String]=[]
    var video_arr:[String]=[]
    var video_str=""
    var images:[String]=[]
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.setForegroundColor(UIColor(rgb: 0x91dbed))
       SVProgressHUD.show()
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        
        addBannerViewToView(bannerView)
        bannerView.adUnitID = "ca-app-pub-4401604271141178/8591872902"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())

        Songtitle.textColor = (UIColor(rgb: 0x91dbed))
        player.delegate = self
        view.backgroundColor = (UIColor(rgb: 0x91dbed))
        reload()
       // resetAudioPlayer()
        
    }
    
    
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
    
   
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        checkInternetConnection()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    func checkInternetConnection(){
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                print("Reachable via WiFi")
            } else {
                print("Reachable via Cellular")
            }
        }
        reachability.whenUnreachable = { _ in
            let alertVC = UIAlertController(title: "Error", message:self.reachability.connection.description , preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertVC.addAction(action)
            self.present(alertVC,animated: true)
        }
    }
    
    

//
//    private func resetAudioPlayer() {
//        var options = STKAudioPlayerOptions()
//        options.flushQueueOnSeek = true
//        options.enableVolumeMixer = true
//        audioPlayer = STKAudioPlayer(options: options)
//
//        // Set up audio player
//        audioPlayer.meteringEnabled = true
//        audioPlayer.volume = 5
//    }
//

    
    func do_table_refresh()
    {
        DispatchQueue.main.async{
            self.loadView()
            
        }
        SVProgressHUD.dismiss()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arr.count
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.4) {
            cell.transform = CGAffineTransform.identity
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: "item", for: indexPath) as! PlayerCollectionViewCell
        collectionView.backgroundColor = (UIColor(rgb: 0x91dbed))
        let delimiter = " "
        let newstr = arr[indexPath.row]
        let token = newstr.components(separatedBy: delimiter)
        item.musicTitle.text = token[0] + " " + token[1]
        item.musicImage.layer.cornerRadius = item.musicImage.frame.width / 2
       item.musicImage.clipsToBounds = true
       item.musicArtist.text = "YouTube"
        item.musicImage.kf.setImage(with: URL(string: images[indexPath.row]))
        item.backgroundColor = (UIColor(rgb: 0x91dbed))
        return item
    }
    
    
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Clicked")
        let y = YoutubeDirectLinkExtractor()
        y.extractInfo(for: .id(video_arr[indexPath.row]), success: { info in
            if self.audioPlayer.state != .playing {
                
                if info.highestQualityPlayableLink == nil{
                    if info.lowestQualityPlayableLink == nil{
                        let alertVC = UIAlertController(title: "Error", message: "Video unavailable", preferredStyle: .alert)
                        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                        alertVC.addAction(action)
                        self.present(alertVC,animated: true)
                    }
                    else{
                            //self.audioPlayer.play(info.lowestQualityPlayableLink!)
                        
                        self.player.radioURL = URL(string: info.highestQualityPlayableLink!)
                        self.player.isAutoPlay = true
                        print("Playing")

                    }
                    
                }
                else
                {
                    self.player.radioURL = URL(string: info.lowestQualityPlayableLink!)
                    self.player.isAutoPlay = true
                    
                //self.audioPlayer.play(info.highestQualityPlayableLink!)
                }
                
            }
//            else if self.audioPlayer.state == .playing{
//               // self.audioPlayer.stop()
//                SVProgressHUD.show(UIImage(named: "PauseFilled") ?? UIImage(named:"play-button")!, status: "Paused")
//
//            }
            
            self.Songtitle.text = self.arr[indexPath.row]
            
        }) { error in
            print(error)
        }
    }


    func reload() {
        let jsonUrlString =
        "https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=25&sp=CAMSBAgDEAE%253D&q=English+Music&key=AIzaSyCSP3HUsmcAPSnUAS877Jac9QzDABnH6NY"
        
        let url = URL(string: jsonUrlString)
        
        URLSession.shared.dataTask(with: url!) { (data, response, err) in
            guard let data = data else { return }
            
            do {
                
                let songs = try JSONDecoder().decode(yt.self, from: data)
                for sng in songs.items {
                    if(sng.id.videoId==nil){
                        self.video_arr.append("xVrNFaeMvP8")
                        self.images.append("https://i.ytimg.com/vi/sGIm0-dQd8M/default.jpg")
                    }else{
                        self.video_arr.append(sng.id.videoId)
                        self.images.append(sng.snippet.thumbnails.medium.url)
                        //print(sng.url.high)
                    }
                    
                    self.arr.append(sng.snippet.title!)
                    
                }
                self.do_table_refresh()
                
            } catch let jsonErr {
                print("Error serializing json:", jsonErr)
            }
            
            }.resume()
        
    }
}
extension UIView {
    
    func animateButtonDown() {
        
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction, .curveEaseIn], animations: {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: nil)
    }
    
    func animateButtonUp() {
        
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
