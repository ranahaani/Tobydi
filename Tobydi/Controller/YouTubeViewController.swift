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
import SVProgressHUD
import GoogleMobileAds
import Reachability
import StreamingKit

class YouTubeViewController: UIViewController,UISearchBarDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UISearchControllerDelegate {
    
    var origImg_play = UIImage(named: "PlayFilled")!
    var songNum = 0

    
    
    
    
    struct musicPlayer{
        static let audioPlayer = STKAudioPlayer()
    }
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
    @IBOutlet weak var collectionView: UICollectionView!
    
    var arr:[String]=[]
    var video_arr:[String]=[]
    var video_str=""
    var images:[String]=[]
    var searchActive : Bool = false
    let searchController = UISearchController(searchResultsController: nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-4401604271141178/8098469764")
        let request = GADRequest()
        interstitial.load(request)
        interstitial = createAndLoadInterstitial()
        let adRequest = GADRequest()
        adRequest.testDevices = [ kGADSimulatorID, "e2d7a1dd28234b89e87a57a0d38d36cd" ]
        adBannerView.load(GADRequest())
        
        SVProgressHUD.setForegroundColor(UIColor(rgb: 0x91dbed))
        SVProgressHUD.show()
        view.backgroundColor = (UIColor(rgb: 0x91dbed))
        reload()
        searchControllerFunction()
        mediaControls_init()
        
    }
    func searchControllerFunction(){
        
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
    }
    
   

    
    func do_table_refresh()
    {
        DispatchQueue.main.async{
            self.collectionView.reloadData()
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
        if token.count >= 2{
            item.musicTitle.text = token[0] + " " + token[1]
        }
        else{
            item.musicTitle.text = token[0]
        }
        
       item.musicArtist.text = "YouTube"
        item.musicImage.kf.setImage(with: URL(string: images[indexPath.row]))
        item.backgroundColor = (UIColor(rgb: 0x91dbed))
        return item
    }
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
        }
        SVProgressHUD.show(withStatus: "Playing...")
        
        let Url = "http://michaelbelgium.me/ytconverter/convert.php?youtubelink=https://www.youtube.com/watch?v=\(video_arr[indexPath.row])"
        
        
        let url = URL(string: Url)
        
        URLSession.shared.dataTask(with: url!) { (data, response, err) in
            guard let data = data else { return }
            
            do {
                
                let downloadedFile = try JSONDecoder().decode(getYouTubeDownloadLink.self, from: data)
                if downloadedFile.file != nil{
                musicPlayer.audioPlayer.play(URL(string:downloadedFile.file)!)
                   
                    SVProgressHUD.dismiss()
                    SVProgressHUD.setSuccessImage(UIImage(named: "PlayFilled")!)
                    SVProgressHUD.showSuccess(withStatus: "Played")
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
        video_arr.removeAll()
        images.removeAll()
        arr.removeAll()
        var searchString = searchController.searchBar.text
        if (searchString?.contains(find: " "))!{
           searchString = searchString?.replace(string: " ", replacement: "+")
        }
        let  jsonUrlString =
        "https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=50&sp=CAMSBAgDEAE%253D&type=music&q=\(searchString ?? "Hollywood")+Music&key=AIzaSyCSP3HUsmcAPSnUAS877Jac9QzDABnH6NY&regionCode=US"
        
        
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


extension YouTubeViewController{
    
    @objc func pressedPlay(button: UIButton) {
        if musicPlayer.audioPlayer.state == .paused {
            //musicPlayer.audioPlayer.play()
            
            origImg_play = UIImage(named: "Pause Filled")!
            
            mediaControls_init()
            
            
        } else if musicPlayer.audioPlayer.state == .playing {
            musicPlayer.audioPlayer.pause()
            
            origImg_play = UIImage(named: "Play Filled")!
            
            mediaControls_init()
        }
    }
    
    @objc func pressedFastf(button: UIButton) {
        songNum = (songNum + 1)%3
        //print(songNum)
        
        if musicPlayer.audioPlayer.state == .paused{
            musicPlayer.audioPlayer.pause()
        } else if musicPlayer.audioPlayer.state == .playing {
           // musicPlayer.audioPlayer.play()
        }
        
    }
    
    @objc func pressedRewind(button: UIButton) {
        if songNum == 0 {
            songNum += 1
        }
       
        if musicPlayer.audioPlayer.state == .paused{
            musicPlayer.audioPlayer.pause()
        } else if musicPlayer.audioPlayer.state == .playing {
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
        
        containerArea.addSubview(playButton)
        containerArea.addSubview(rewindButton)
        containerArea.addSubview(fastfButton)
        
        //Add button constraints
        let containerAreaConstraints: [NSLayoutConstraint] = [
            containerArea.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerArea.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerArea.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -tabbarHeight!),
            containerArea.heightAnchor.constraint(equalToConstant: 70),
            
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


extension YouTubeViewController: GADBannerViewDelegate {
    
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

extension YouTubeViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        //collectionView.reloadData()
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

