//
//  ShahzamViewController.swift
//  Tobydi
//
//  Created by Muhammad Abdullah on 13/01/2019.
//  Copyright © 2019 Muhammad Abdullah. All rights reserved.
//
import UIKit
import Kingfisher
import AVFoundation
import SVProgressHUD
import Alamofire
import SQLite3
import GoogleMobileAds
import Reachability


 


class ShahzamViewController: UIViewController,UISearchBarDelegate,UISearchControllerDelegate {
    let dict:[String:Any] = [String:Any]()
   var searchActive = false
    var timer: Timer? = nil
    var origImg_play = UIImage(named: "PlayFilled")!
    var songNum = 0
    var slider: UISlider? = UISlider(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var isFirstTime = true
   var titles = [String]()
   var ids = [String]()
   var images = [String]()
    var owner = [String]()
    var bannerView: GADBannerView!
    var interstitial: GADInterstitial!
    var rows=0
    lazy var adBannerView: GADBannerView = {
        let adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView.adUnitID = "ca-app-pub-8501671653071605/1974659335"
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        
        return adBannerView
    }()
    let searchController = UISearchController(searchResultsController: nil)
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-4401604271141178/8098469764")
        let request = GADRequest()
        interstitial.load(request)
        interstitial = createAndLoadInterstitial()
        let adRequest = GADRequest()
        adRequest.testDevices = [ kGADSimulatorID, "e2d7a1dd28234b89e87a57a0d38d36cd" ]
        adBannerView.load(GADRequest())
        slider?.translatesAutoresizingMaskIntoConstraints = false
        
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = true
        self.searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        searchController.searchBar.becomeFirstResponder()
        self.navigationItem.titleView = searchController.searchBar
        self.definesPresentationContext = true
        self.searchController.searchBar.placeholder = "Search for Audio"
        
        mediaControls_init()
        getDataFromApi()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
        }// Do any additional setup after loading the view.
    }
    
  
}


extension ShahzamViewController{
    @objc func sliderChanged() {
        
        print("Slider Changed: \(slider!.value)")
        
        YouTubeViewController.musicPlayer.audioPlayer.seek(toTime: Double(slider!.value))
    }
    
    func setupTimer() {
        timer = Timer(timeInterval: 0.001, target: self, selector: #selector(self.tick), userInfo: nil, repeats: true)
        
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    func stopButtonPressed() {
        YouTubeViewController.musicPlayer.audioPlayer.stop()
    }
    func playButtonPressed() {
        //        if musicPlayer.audioPlayer {
        //            return
        //        }
        
        if YouTubeViewController.musicPlayer.audioPlayer.state == .paused {
            YouTubeViewController.musicPlayer.audioPlayer.resume()
        } else {
            YouTubeViewController.musicPlayer.audioPlayer.pause()
        }
    }
    
    func formatTime(fromSeconds totalSeconds: Int) -> String? {
        
        let seconds = totalSeconds % 60
        let minutes = (totalSeconds / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    @objc func tick() {
        
        
        
        if YouTubeViewController.musicPlayer.audioPlayer.duration != 0 {
            slider!.minimumValue = 0
            slider!.maximumValue = Float(YouTubeViewController.musicPlayer.audioPlayer.duration)
            slider!.value = Float(YouTubeViewController.musicPlayer.audioPlayer.progress)
            
            //            label.text = "\(formatTime(fromSeconds: audioPlayer.progress)) - \(formatTime(fromSeconds: audioPlayer.duration))"
        } else {
            slider!.value = 0
            slider!.minimumValue = 0
            slider!.maximumValue = 0
            
            //  label.text = "Live stream \(formatTime(fromSeconds: audioPlayer.progress))"
        }
        
        //statusLabel.text = audioPlayer.state == STKAudioPlayerStateBuffering ? "buffering" : ""
        
    }
    
    
}

extension ShahzamViewController{
    
    @objc func pressedPlay(button: UIButton) {
        if YouTubeViewController.musicPlayer.audioPlayer.state == .paused {
            //playMusic(indexPath: songNum)
            origImg_play = UIImage(named: "PauseFilled")!
            mediaControls_init()
            
        } else if YouTubeViewController.musicPlayer.audioPlayer.state == .playing {
            YouTubeViewController.musicPlayer.audioPlayer.pause()
            
            origImg_play = UIImage(named: "PlayFilled")!
            
            mediaControls_init()
        }
    }
    
    @objc func pressedFastf(button: UIButton) {
        songNum += 1
        //playMusic(indexPath: songNum)
        
        if YouTubeViewController.musicPlayer.audioPlayer.state == .paused{
            YouTubeViewController.musicPlayer.audioPlayer.pause()
        } else if YouTubeViewController.musicPlayer.audioPlayer.state == .playing {
            // musicPlayer.audioPlayer.play()
        }
        
    }
    
    @objc func pressedRewind(button: UIButton) {
        if songNum == 0 {
            songNum += 1
        }
        else{
            songNum -= 1
        }
        //playMusic(indexPath: songNum)
        if YouTubeViewController.musicPlayer.audioPlayer.state == .paused{
            YouTubeViewController.musicPlayer.audioPlayer.pause()
        } else if YouTubeViewController.musicPlayer.audioPlayer.state == .playing {
            // musicPlayer.audioPlayer.play()
        }
    }
    
    @objc func someAction(button: UIButton) {
        print("some action")
    }
    
    private func mediaControls_init() {
        let tabbarHeight = tabBarController?.tabBar.frame.height
        //Create a container for buttons
        
        let containerArea = UIView()
        containerArea.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0)
        containerArea.layer.borderWidth = 2
        containerArea.layer.borderColor = UIColor.lightGray.cgColor
        containerArea.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerArea)
        
        //Add Rewind, Play, Fast Forward
        let origImg_rewind = UIImage(named: "Rewind Filled")!
        let tintedImg_rewind = origImg_rewind.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        let rewindButton = UIButton()
        
        let tintedImg_play = origImg_play.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        let playButton = UIButton()
        
        let origImg_fastf = UIImage(named: "Fast Forward Filled")!
        let tintedImg_fastf = origImg_fastf.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        let fastfButton = UIButton()
        
        //Set button specifications
        let tinted_dict = [rewindButton: tintedImg_rewind, playButton: tintedImg_play, fastfButton: tintedImg_fastf]
        
        let button_ls = [rewindButton,playButton,fastfButton]
        
        for button in button_ls {
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setContentHuggingPriority(UILayoutPriority(rawValue: 251), for: .horizontal)
            button.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 751), for: .horizontal)
            button.setImage(tinted_dict[button], for: .normal)
            button.tintColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1)
        }
        
        //Set button actions and add to subviews
        rewindButton.addTarget(self, action: #selector(pressedRewind(button:)), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(pressedPlay(button:)), for: .touchUpInside)
        fastfButton.addTarget(self, action: #selector(pressedFastf(button:)), for: .touchUpInside)
        slider!.isContinuous = true
        slider!.addTarget(self, action: #selector(self.sliderChanged), for: .valueChanged)
        containerArea.addSubview(slider!)
        containerArea.addSubview(playButton)
        containerArea.addSubview(rewindButton)
        containerArea.addSubview(fastfButton)
        
        //Add button constraints
        let containerAreaConstraints: [NSLayoutConstraint] = [
            containerArea.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerArea.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerArea.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -tabbarHeight!),
            containerArea.heightAnchor.constraint(equalToConstant: 80),
            
            (slider?.leadingAnchor.constraint(equalTo: containerArea.leadingAnchor))!,
            (slider?.trailingAnchor.constraint(equalTo: containerArea.trailingAnchor))!,
            (slider?.bottomAnchor.constraint(equalTo: containerArea.topAnchor,constant: 28))!,
            
            rewindButton.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -30),
            playButton.centerXAnchor.constraint(equalTo: containerArea.centerXAnchor),
            fastfButton.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 30),
            
            rewindButton.centerYAnchor.constraint(equalTo: containerArea.centerYAnchor),
            playButton.centerYAnchor.constraint(equalTo: containerArea.centerYAnchor),
            fastfButton.centerYAnchor.constraint(equalTo: containerArea.centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(containerAreaConstraints)
    }
    
}


extension ShahzamViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ids.count
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.4) {
            cell.transform = CGAffineTransform.identity
        } 
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //print(titleArr)
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: "item", for: indexPath) as! PlayerCollectionViewCell
        collectionView.backgroundColor = (UIColor(rgb: 0x91dbed))
        item.musicTitle.text = titles[indexPath.row]
        item.musicArtist.text = "Shahzam"
        item.musicImage.kf.setImage(with: URL(string: images[indexPath.row]))
        item.backgroundColor = (UIColor(rgb: 0x91dbed))
        return item
    }
    
    func getDataFromApi(){
        ids.removeAll()
        images.removeAll()
        titles.removeAll()
        SVProgressHUD.show(withStatus: "Loading...")
        let searchString = searchController.searchBar.text?.replace(string: " ", replacement: "%20")
        var jsonUrlString = ""
        if isFirstTime{
              jsonUrlString = "https://api.audioboom.com/audio_clips?find[query]=Justin%20songs"
            isFirstTime = false
        }else{
            jsonUrlString = "https://api.audioboom.com/audio_clips?find[query]=\(searchString ?? "")"
        }
        
        
        print(jsonUrlString)
        let url = URL(string: jsonUrlString)
        print(url)
        Alamofire.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default)
            .responseJSON { response in
                if let status = response.response?.statusCode {
                    switch(status){
                    case 201:
                        print("example success")
                    default:
                        print("error with response status: \(status)")
                        SVProgressHUD.showError(withStatus: "Error")
                    }
                }
                if let result = response.result.value {
                    let JSON = result as! NSDictionary
                    let body = JSON["body"] as! NSDictionary
                    let audio_clips = body["audio_clips"] as! [NSDictionary]
                    for audio in audio_clips{
                        self.titles.append(audio["title"] as! String)
                        let user = audio["user"] as! NSDictionary
                        let urls = user["urls"] as! NSDictionary
                        self.images.append(urls["image"] as! String)
                        let urlss = audio["urls"] as! NSDictionary
                        self.ids.append(urlss["high_mp3"] as! String)
                        
                    }
                    
                    self.collectionView.reloadData()
                    SVProgressHUD.dismiss()
                }
                
        }
        
        }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
        }
        YouTubeViewController.musicPlayer.audioPlayer.play(URL(string: ids[indexPath.row])!)
        DispatchQueue.main.async {
            self.setupTimer()
            self.origImg_play = UIImage(named: "PauseFilled")!
            self.mediaControls_init()
        }
    }
    
}

extension ShahzamViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        collectionView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        SVProgressHUD.dismiss()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
        //collectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        SVProgressHUD.show(withStatus: "Searching...")
        getDataFromApi()
        DispatchQueue.main.async{
            self.collectionView.reloadData()
            
        }
        //collectionView.reloadData()
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        if !searchActive {
            searchActive = true
           collectionView.reloadData()
        }
        
        searchController.searchBar.resignFirstResponder()
    }
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
}
extension ShahzamViewController: GADBannerViewDelegate {
    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-4401604271141178/8098469764")
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
    }
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Banner loaded successfully")
        collectionView.addSubview(bannerView)
        collectionView.contentInset.top = 100
        
        bannerView.frame = CGRect(x: 0,
                                  y: -80,
                                  width: collectionView.frame.size.width,
                                  height: 80)
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Fail to receive ads")
        print(error)
    }
    
    
}
