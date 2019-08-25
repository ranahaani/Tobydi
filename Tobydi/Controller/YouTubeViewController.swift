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
import FRadioPlayer
import CoreData
import StreamingKit
import AudioIndicatorBars
class YouTubeViewController: UIViewController,UISearchBarDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UISearchControllerDelegate {
    let defaults = UserDefaults.standard
    var selectedIndex = 0 {
        didSet {
            defer {
                playMusic(indexPath: selectedIndex)
                //updateNowPlaying(with: track)
            }
            
            guard 0..<video_arr.endIndex ~= selectedIndex else {
                selectedIndex = selectedIndex < 0 ? video_arr.count - 1 : 0
                return
            }
        }
    }
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    let indicator: AudioIndicatorBarsView =
        AudioIndicatorBarsView(
            CGRect(x: 10, y: 35, width: 25, height: 25),
            4,
            2,
            #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    )
    let indicator2: AudioIndicatorBarsView =
        AudioIndicatorBarsView(
            CGRect(x: 10, y: 300, width: 25, height: 25),
            4,
            2,
            #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    )
    
    var timer: Timer? = nil
    var origImg_play = UIImage(named: "PlayFilled")!
    var songNum = 0
    var slider: UISlider? = UISlider(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    struct musicPlayer{
        static let audioPlayer2 = STKAudioPlayer()
        static let audioPlayer = FRadioPlayer.shared

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
        slider?.translatesAutoresizingMaskIntoConstraints = false
        musicPlayer.audioPlayer.delegate = self

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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
        }// Do any additional setup after loading the view.
    }

    @IBAction func addToFavouritePressed(_ sender: UIButton) {
       // sender.imageView?.image = UIImage(named: "like")
       // print("Clicked")
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
        item.heartButtonPressed.tag = indexPath.row
        item.heartButtonPressed.addTarget(self, action: #selector(heartButtonClicked(_:)), for: .touchUpInside)
        item.musicArtist.text = "YouTube"
        item.musicImage.kf.setImage(with: URL(string: images[indexPath.row]))
        item.backgroundColor = (UIColor(rgb: 0x91dbed))
        return item
    }
    
    @objc func heartButtonClicked(_ sender: UIButton){
        sender.setImage(UIImage(named: "like"), for: .normal)
        //let value = Favourite(title: arr[sender.tag], playID: video_arr[sender.tag], category: "youtube")
        //defaults.setValue(value, forKey: "YT\(sender.tag)")
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Fav", in: context)
        let song = NSManagedObject(entity: entity!, insertInto: context)
        song.setValue(arr[sender.tag], forKey: "name")
        song.setValue(video_arr[sender.tag], forKey: "audioID")
        song.setValue("YT", forKey: "cat")
        song.setValue(images[sender.tag], forKey: "image")
        song.setValue(sender.tag, forKey: "id")
        do {
            try context.save()
        } catch {
            print("Failed saving")
        }
        print(sender.tag)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
        }
        
        playMusic(indexPath: indexPath.row)
        
    }
    func playMusic(indexPath:Int){
        let Url = "https://warm-lake-76314.herokuapp.com/index/\(video_arr[indexPath])"
        print(Url)
        let url = URL(string: Url)
        SVProgressHUD.show(withStatus: "Playing...")
        

        URLSession.shared.dataTask(with: url!) { (data, response, err) in
            guard let data = data else { return }
            
            do {
                let str = String(decoding: data, as: UTF8.self)
                print(str,str.count)
                if  str.count != 0 && str.count < 1000{
                    
                  musicPlayer.audioPlayer.radioURL = URL(string: str)
                    //musicPlayer.audioPlayer.play()

                    
                }
                else{
                    self.ShowAlert(title: "Error", message: "HTTP Error 429: Too Many Requests or 402")
                    SVProgressHUD.dismiss()
                }
                
            } catch let jsonErr {
                self.ShowAlert(title: "Error", message: jsonErr.localizedDescription)
                print("Error serializing json:", jsonErr)
            }
            
            }.resume()
        
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
    @objc func sliderChanged() {
        slider!.maximumValue = Float(musicPlayer.audioPlayer.rate ?? 0)
        print("Slider Changed: \(slider!.value)")
        //musicPlayer.audioPlaye
        //musicPlayer.audioPlayer.rate(toTime: Double(slider!.value))
    }
    
    func setupTimer() {
        timer = Timer(timeInterval: 0.001, target: self, selector: #selector(self.tick), userInfo: nil, repeats: true)
        
        RunLoop.current.add(timer!, forMode: .common)
    }

    func stopButtonPressed() {
        musicPlayer.audioPlayer.stop()
    }
    func playButtonPressed() {
        musicPlayer.audioPlayer.togglePlaying()
    }
    
    func formatTime(fromSeconds totalSeconds: Int) -> String? {
        
        let seconds = totalSeconds % 60
        let minutes = (totalSeconds / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    @objc func tick() {
       
        if musicPlayer.audioPlayer.rate != 0 {
            slider!.minimumValue = 0
            slider!.maximumValue = Float(musicPlayer.audioPlayer.rate ?? 0)
            slider!.value = Float(musicPlayer.audioPlayer.hashValue)
            
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

extension YouTubeViewController{
    
    @objc func pressedPlay(button: UIButton) {
//        if musicPlayer.audioPlayer.state == .loading {
//            playMusic(indexPath: songNum)
//            origImg_play = UIImage(named: "PauseFilled")!
//            indicator.start()
//            mediaControls_init()
//
//        } else if musicPlayer.audioPlayer.state == .readyToPlay {
//            musicPlayer.audioPlayer.pause()
//            indicator.stop()
//            origImg_play = UIImage(named: "PlayFilled")!
//
//            mediaControls_init()
//        }
        musicPlayer.audioPlayer.togglePlaying()
        mediaControls_init()
    }
    
    @objc func pressedFastf(button: UIButton) {
        selectedIndex += 1
    }
    
    @objc func pressedRewind(button: UIButton) {
       selectedIndex -= 1
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
        indicator2.translatesAutoresizingMaskIntoConstraints = false
        indicator.translatesAutoresizingMaskIntoConstraints = false
        //Set button actions and add to subviews
        rewindButton.addTarget(self, action: #selector(pressedRewind(button:)), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(pressedPlay(button:)), for: .touchUpInside)
        fastfButton.addTarget(self, action: #selector(pressedFastf(button:)), for: .touchUpInside)
        slider!.isContinuous = true
        slider!.addTarget(self, action: #selector(self.sliderChanged), for: .valueChanged)
        //containerArea.addSubview(slider!)
        containerArea.addSubview(playButton)
        containerArea.addSubview(rewindButton)
        containerArea.addSubview(fastfButton)
        containerArea.addSubview(indicator)
        containerArea.addSubview(indicator2)
        //Add button constraints
        let containerAreaConstraints: [NSLayoutConstraint] = [
            containerArea.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerArea.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerArea.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -tabbarHeight!),
            containerArea.heightAnchor.constraint(equalToConstant: 80),
            
            //(slider?.leadingAnchor.constraint(equalTo: containerArea.leadingAnchor))!,
            //(slider?.trailingAnchor.constraint(equalTo: containerArea.trailingAnchor))!,
            //(slider?.bottomAnchor.constraint(equalTo: containerArea.topAnchor,constant: 28))!,
            
            rewindButton.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -30),
            playButton.centerXAnchor.constraint(equalTo: containerArea.centerXAnchor),
            fastfButton.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 30),
            
            rewindButton.centerYAnchor.constraint(equalTo: containerArea.centerYAnchor),
            playButton.centerYAnchor.constraint(equalTo: containerArea.centerYAnchor),
            fastfButton.centerYAnchor.constraint(equalTo: containerArea.centerYAnchor),
            
            indicator.widthAnchor.constraint(equalToConstant: 25.0),
            indicator.heightAnchor.constraint(equalToConstant: 25.0),
            indicator.trailingAnchor.constraint(equalTo: containerArea.trailingAnchor, constant: -20),
            indicator.centerYAnchor.constraint(equalTo: containerArea.centerYAnchor, constant: 0),
            
            indicator2.widthAnchor.constraint(equalToConstant: 25.0),
            indicator2.heightAnchor.constraint(equalToConstant: 25.0),
            indicator2.leadingAnchor.constraint(equalTo: containerArea.leadingAnchor, constant: 20),
            indicator2.centerYAnchor.constraint(equalTo: containerArea.centerYAnchor, constant: 0)
        ]
        
        NSLayoutConstraint.activate(containerAreaConstraints)
    }
    
}


extension YouTubeViewController: FRadioPlayerDelegate {

    func radioPlayer(_ player: FRadioPlayer, playerStateDidChange state: FRadioPlayerState) {
       // statusLabel.text = state.description
    }
    
    func radioPlayer(_ player: FRadioPlayer, playbackStateDidChange state: FRadioPlaybackState) {
        if state == .playing && musicPlayer.audioPlayer2.state != .playing {
            SVProgressHUD.dismiss()
            DispatchQueue.main.async{
                self.origImg_play = UIImage(named: "PauseFilled")!
                self.indicator.start()
                self.indicator2.start()
                print("Playing....")
                //self.setupTimer()
                self.mediaControls_init()
                //self.tick()
            }
        }
        else if state == .paused{
            SVProgressHUD.dismiss()
            DispatchQueue.main.async{
                self.origImg_play = UIImage(named: "PlayFilled")!
                self.indicator.stop()
                self.indicator2.stop()
                print("Paused....")
                self.setupTimer()
                self.mediaControls_init()
                //self.tick()
            }
        }
        else if state == .stopped{
            //SVProgressHUD.dismiss()
            DispatchQueue.main.async{
                self.origImg_play = UIImage(named: "PlayFilled")!
                self.indicator.stop()
                self.indicator2.stop()
                print("stopped....")
                self.setupTimer()
                self.mediaControls_init()
                self.tick()
            }
        }
        
    }
    
    func radioPlayer(_ player: FRadioPlayer, metadataDidChange artistName: String?, trackName: String?) {
        //track = Track(artist: artistName, name: trackName)
    }
    
    func radioPlayer(_ player: FRadioPlayer, itemDidChange url: URL?) {
        //track = nil
    }
    
    func radioPlayer(_ player: FRadioPlayer, metadataDidChange rawValue: String?) {
       // infoContainer.isHidden = (rawValue == nil)
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
        bannerView.frame = CGRect(x: 0,
                                  y: -80,
                                  width: collectionView.frame.size.width,
                                  height: 80)
        view.addSubview(bannerView)
        collectionView.contentInset.top = 100
        
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

extension UIViewController{
    func ShowAlert(title:String,message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler: { (action) in alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
