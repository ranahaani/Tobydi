//
//  soundclodViewController.swift
//  Tobydi
//
//  Created by Muhammad Abdullah on 17/01/2019.
//  Copyright © 2019 Muhammad Abdullah. All rights reserved.
//



import UIKit
import Kingfisher
import GoogleMobileAds
import AVFoundation
import SVProgressHUD
import Reachability
import StreamingKit
class soundcloudViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource ,UISearchBarDelegate,UISearchControllerDelegate{
    var isFirstTime = true
    var timer: Timer? = nil
    var origImg_play = UIImage(named: "PlayFilled")!
    var songNum = 0
    var slider: UISlider? = UISlider(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    @IBOutlet weak var collectionView: UICollectionView!
    let reachability = Reachability()!
    var interstitial: GADInterstitial!
    var trackURL:[String]=[]
    var trackArtist:[String]=[]
    var trackImages:[String]=[]
    var trackName:[String]=[]
    var searchActive : Bool = false
    let searchController = UISearchController(searchResultsController: nil)
    var bannerView: GADBannerView!
    var rows=0
    lazy var adBannerView: GADBannerView = {
        let adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView.adUnitID = "ca-app-pub-8501671653071605/1974659335"
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        
        return adBannerView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-4401604271141178/8098469764")
        let request = GADRequest()
        interstitial.load(request)
        interstitial = createAndLoadInterstitial()
        let adRequest = GADRequest()
        adRequest.testDevices = [ kGADSimulatorID, "e2d7a1dd28234b89e87a57a0d38d36cd" ]
        adBannerView.load(GADRequest())
        
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
        SVProgressHUD.show()
        
        SVProgressHUD.setForegroundColor(UIColor(rgb: 0x91dbed))
        SVProgressHUD.show()
        view.backgroundColor = (UIColor(rgb: 0x91dbed))
        reload()
       mediaControls_init()
        setupTimer()
        
        
    }
  
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
        }// Do any additional setup after loading the view.
    }
    
    func do_table_refresh()
    {
        
        DispatchQueue.main.async{
            self.collectionView.reloadData()
        }
        SVProgressHUD.dismiss()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trackName.count
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
        item.musicTitle.text = trackName[indexPath.row]
       // item.musicArtist.text = trackArtist[indexPath.row]
        item.musicImage.kf.setImage(with: URL(string: trackImages[indexPath.row]))
        item.backgroundColor = (UIColor(rgb: 0x91dbed))
        return item
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        SVProgressHUD.show(withStatus: "Playing...")
       
        playMusic(indexPath: indexPath.row)
        
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
        }
        
    }
    
    
    func playMusic(indexPath:Int){
        let Url = "https://ranahaani.herokuapp.com/json?url=\(trackURL[indexPath])"
        print(Url)
        print(Url)
        let url = URL(string: Url)
        
        URLSession.shared.dataTask(with: url!) { (data, response, err) in
            guard let data = data else { return }
            
            do {
                
                let downloadedFile = try JSONDecoder().decode(getsoundclodDownloadable.self, from: data)
                if downloadedFile.formats.count > 0{
                    for mp3Song in downloadedFile.formats{
                        if let playLink = mp3Song.url{
                            YouTubeViewController.musicPlayer.audioPlayer.play(URL(string:playLink)!)
                            print(mp3Song.url)
                            SVProgressHUD.dismiss()
                            SVProgressHUD.setSuccessImage(UIImage(named: "PlayFilled")!)
                            SVProgressHUD.showSuccess(withStatus: "Played")
                        }
                    }
                }
                else{
                    self.ShowAlert(title: "Error", message: "Sorry Some Error Found")
                }
                
                
                
            } catch let jsonErr {
                self.ShowAlert(title: "Error", message: jsonErr.localizedDescription)
                print("Error serializing json:", jsonErr)
            }
            
            }.resume()
        
        
    }
    
    func ShowAlert(title:String,message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler: { (action) in alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    func reload() {
        trackURL.removeAll()
        trackImages.removeAll()
        trackName.removeAll()
        trackArtist.removeAll()
        var jsonUrlString = ""
        var searchString = searchController.searchBar.text
        if (searchString?.contains(find: " "))!{
            searchString = searchString?.replace(string: " ", replacement: "+")
        }
        if isFirstTime{
             jsonUrlString =
            "https://api.mixcloud.com/search/?q=\(searchString ?? "Bebe")+Rexha&amp;type=cloudcast&limit=100"
            isFirstTime = false
        }
        else{
            jsonUrlString.removeAll()
            jsonUrlString =
            "https://api.mixcloud.com/search/?q=\(searchString ?? "")&amp;type=cloudcast&limit=100"
        }
        
        let url = URL(string: jsonUrlString)
        URLSession.shared.dataTask(with: url!) { (data, response, err) in
            guard let data = data else { return }
            
            do {
                
                let songs = try JSONDecoder().decode(soundclod.self, from: data)
                for sng in songs.data {
                    self.trackURL.append(sng.url!)
                    self.trackName.append(sng.name!)
                    self.trackImages.append((sng.pictures?.medium)!)
                }
                self.do_table_refresh()
                
            } catch let jsonErr {
                print("Error serializing json:", jsonErr.localizedDescription)
            }
            
            }.resume()
        
    }

}


extension soundcloudViewController{
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

extension soundcloudViewController{
    
    @objc func pressedPlay(button: UIButton) {
        if YouTubeViewController.musicPlayer.audioPlayer.state == .paused {
            playMusic(indexPath: songNum)
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
        playMusic(indexPath: songNum)
        
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
        playMusic(indexPath: songNum)
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





extension soundcloudViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        collectionView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
        // collectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        reload()
        SVProgressHUD.show(withStatus: "Searching...")
        collectionView.reloadData()
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        if !searchActive {
            searchActive = true
            collectionView.reloadData()
        }
        
        searchController.searchBar.resignFirstResponder()
    }
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
}
}
extension soundcloudViewController: GADBannerViewDelegate {
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
