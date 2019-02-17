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
import HCYoutubeParser
import Reachability
class YouTubeViewController: UIViewController,FRadioPlayerDelegate,UICollectionViewDelegate,UICollectionViewDataSource {
    
    var bannerView: GADBannerView!

    let player = FRadioPlayer.shared

    let reachability = Reachability()!
    var audioPlayer = STKAudioPlayer()
    let y = YoutubeDirectLinkExtractor()
    @IBOutlet weak var Songtitle: MarqueeLabel!
    @IBOutlet weak var videoView: UIView!
    var rows=0
    lazy var adBannerView: GADBannerView = {
        let adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView.adUnitID = "ca-app-pub-8501671653071605/1974659335"
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        
        return adBannerView
    }()
    @IBOutlet weak var collectionView: UICollectionView!
    var arr:[String]=[]
    var video_arr:[String]=[]
    var video_str=""
    var audioLinks = [String]()
    var images:[String]=[]
    override func viewDidLoad() {
        super.viewDidLoad()
        checkInternetConnection()
        SVProgressHUD.setForegroundColor(UIColor(rgb: 0x91dbed))
       SVProgressHUD.show()
        let adRequest = GADRequest()
        adRequest.testDevices = [ kGADSimulatorID, "e2d7a1dd28234b89e87a57a0d38d36cd" ]
        adBannerView.load(GADRequest())
        Songtitle.textColor = (UIColor(rgb: 0x91dbed))
        player.delegate = self
        view.backgroundColor = (UIColor(rgb: 0x91dbed))
        reload()
        
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
        let token = arr[indexPath.row].components(separatedBy: " ")
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
        SVProgressHUD.show()
        y.extractInfo(for: .id(video_arr[indexPath.row]), success: { info in
            
            print(info.lowestQualityPlayableLink,info.highestQualityPlayableLink,info.rawInfo[2]["url"],info.rawInfo[1]["url"],info.rawInfo[0]["url"])
            SVProgressHUD.dismiss()
            SVProgressHUD.setSuccessImage(UIImage(named: "PlayFilled")!)
            SVProgressHUD.showSuccess(withStatus: "Playing")
            if info.rawInfo[0]["url"] != nil{
                self.audioPlayer.play(info.rawInfo[1]["url"]!)
            }
            else if info.rawInfo[1]["url"] != nil{
                self.audioPlayer.play(info.rawInfo[2]["url"]!)
            }
            else if info.rawInfo[2]["url"] != nil{
                self.audioPlayer.play(info.rawInfo[0]["url"]!)
            }
            else if info.highestQualityPlayableLink != nil{
                self.audioPlayer.play(info.highestQualityPlayableLink!)
            }
            else if info.lowestQualityPlayableLink != nil{
                self.audioPlayer.play(info.lowestQualityPlayableLink!)
            }
            else{
                self.ShowAlert(title: "Alert", message: "Can't be played")
            }
            
            self.Songtitle.text = self.arr[indexPath.row]
            
        }) { error in
            
            self.ShowAlert(title: "Error", message: error.localizedDescription)
            SVProgressHUD.dismiss()
            print(error.localizedDescription)
        }
    }

    func radioPlayer(_ player: FRadioPlayer, playerStateDidChange state: FRadioPlayerState) {
       // SVProgressHUD.show(UIImage(named: "PauseFilled") ??UIImage(named:"play-button")!, status: "Paused")
    }
    
    func radioPlayer(_ player: FRadioPlayer, playbackStateDidChange state: FRadioPlaybackState) {
        //SVProgressHUD.show()
        //SVProgressHUD.show(UIImage(named: "PlayFilled") ?? UIImage(named:"play-button")!, status: "Played")
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

extension YouTubeViewController: GADBannerViewDelegate {
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Banner loaded successfully")
        videoView.frame = bannerView.frame
        videoView = bannerView
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Fail to receive ads")
        print(error)
    }
    
    func ShowAlert(title:String,message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler: { (action) in alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
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
