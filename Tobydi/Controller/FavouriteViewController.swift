//
//  FavouriteViewController.swift
//  Tobydi
//
//  Created by Muhammad Abdullah on 20/08/2019.
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

class FavouriteViewController: UIViewController,UISearchBarDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UISearchControllerDelegate {
    
    var searchActive : Bool = false
    let searchController = UISearchController(searchResultsController: nil)
    var selectedIndex = 0 {
        didSet {
            defer {
                playMusic(indexPath: selectedIndex)
                mediaControls_init()
            }
            
            guard 0..<favouriteSongs.endIndex ~= selectedIndex else {
                selectedIndex = selectedIndex < 0 ? favouriteSongs.count - 1 : 0
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
    
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Fav")
    @IBOutlet weak var collectionView: UICollectionView!
    var favouriteSongs:[Favourite] = [Favourite]()
    override func viewDidLoad() {
        super.viewDidLoad()
        mediaControls_init()
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-4401604271141178/8098469764")
        let request = GADRequest()
        interstitial.load(request)
        interstitial = createAndLoadInterstitial()
        let adRequest = GADRequest()
        adRequest.testDevices = [ kGADSimulatorID, "e2d7a1dd28234b89e87a57a0d38d36cd" ]
        adBannerView.load(GADRequest())
        searchControllerFunction()
        view.backgroundColor = (UIColor(rgb: 0x91dbed))

        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
        }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        request.returnsObjectsAsFaults = false
        do {
            
            let result = try context.fetch(request)
            favouriteSongs.removeAll()
            for data in result as! [NSManagedObject] {
                let favSong = Favourite(
                    title: data.value(forKey: "name") as! String,
                    image: data.value(forKey: "image") as! String,
                    playID: data.value(forKey: "audioID") as! String,
                    category: data.value(forKey: "cat") as! String)
                
                favouriteSongs.append(favSong)
                collectionView.reloadData()
                //print(data.value(forKey: "name") as! String)
                
            }
            
        } catch {
            
            print("Failed")
        }
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
        
        switch favouriteSongs[indexPath].category {
        case "YT":
            let Url = "https://warm-lake-76314.herokuapp.com/index/\(favouriteSongs[indexPath].playID)"
            print(Url)
            let url = URL(string: Url)
            SVProgressHUD.show(withStatus: "Playing...")
            
            
            URLSession.shared.dataTask(with: url!) { (data, response, err) in
                guard let data = data else { return }
                
                do {
                    let str = String(decoding: data, as: UTF8.self)
                    print(str,str.count)
                    if  str.count != 0 && str.count < 1000{
                        
                        YouTubeViewController.musicPlayer.audioPlayer.radioURL = URL(string: str)
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
            
        case "SC":
            let Url = "https://ranahaani.herokuapp.com/json?url=\(favouriteSongs[indexPath].playID)"
            print(Url)
            let url = URL(string: Url)
            
            URLSession.shared.dataTask(with: url!) { (data, response, err) in
                guard let data = data else { return }
                
                do {
                    
                    let downloadedFile = try JSONDecoder().decode(getsoundclodDownloadable.self, from: data)
                    if downloadedFile.formats.count > 0{
                        for mp3Song in downloadedFile.formats{
                            if let playLink = mp3Song.url{
                                YouTubeViewController.musicPlayer.audioPlayer2.play(URL(string:playLink)!)
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
        default:
            YouTubeViewController.musicPlayer.audioPlayer2.play(URL(string: favouriteSongs[indexPath].playID)!)
            DispatchQueue.main.async {
                self.setupTimer()
                SVProgressHUD.dismiss()
                self.origImg_play = UIImage(named: "PauseFilled")!
                self.mediaControls_init()
            }
        }
        
        
       
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favouriteSongs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: "item", for: indexPath) as! PlayerCollectionViewCell
        collectionView.backgroundColor = (UIColor(rgb: 0x91dbed))
        let token = favouriteSongs[indexPath.row].title.components(separatedBy: " ")
        if token.count >= 2{
            item.musicTitle.text = token[0] + " " + token[1]
        }
        else{
            item.musicTitle.text = token[0]
        }
        //item.heartButtonPressed.tag = indexPath.row
        //item.heartButtonPressed.addTarget(self, action: #selector(heartButtonClicked(_:)), for: .touchUpInside)
        item.musicArtist.text = "YouTube"
        item.musicImage.kf.setImage(with: URL(string: favouriteSongs[indexPath.row].image))
        item.backgroundColor = (UIColor(rgb: 0x91dbed))
        return item
    }
}

extension FavouriteViewController: GADBannerViewDelegate {
    
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

extension FavouriteViewController{
    @objc func sliderChanged() {
        slider!.maximumValue = Float(YouTubeViewController.musicPlayer.audioPlayer.rate ?? 0)
        print("Slider Changed: \(slider!.value)")
        //musicPlayer.audioPlaye
        //musicPlayer.audioPlayer.rate(toTime: Double(slider!.value))
    }
    
    func setupTimer() {
        timer = Timer(timeInterval: 0.001, target: self, selector: #selector(self.tick), userInfo: nil, repeats: true)
        
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    func stopButtonPressed() {
        YouTubeViewController.musicPlayer.audioPlayer.stop()
    }
    func playButtonPressed() {
        YouTubeViewController.musicPlayer.audioPlayer.togglePlaying()
    }
    
    func formatTime(fromSeconds totalSeconds: Int) -> String? {
        
        let seconds = totalSeconds % 60
        let minutes = (totalSeconds / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    @objc func tick() {
        
        if YouTubeViewController.musicPlayer.audioPlayer.rate != 0 {
            slider!.minimumValue = 0
            slider!.maximumValue = Float(YouTubeViewController.musicPlayer.audioPlayer.rate ?? 0)
            slider!.value = Float(YouTubeViewController.musicPlayer.audioPlayer.hashValue)
            
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
extension FavouriteViewController{
    
    @objc func pressedPlay(button: UIButton) {
        if YouTubeViewController.musicPlayer.audioPlayer2.state == .paused {
            playMusic(indexPath: songNum)
            origImg_play = UIImage(named: "PauseFilled")!
            mediaControls_init()
            
        } else if YouTubeViewController.musicPlayer.audioPlayer2.state == .playing {
            YouTubeViewController.musicPlayer.audioPlayer2.pause()
            
            origImg_play = UIImage(named: "PlayFilled")!
            
            mediaControls_init()
        }
    }
    
    @objc func pressedFastf(button: UIButton) {
        songNum += 1
        playMusic(indexPath: songNum)
        
        if YouTubeViewController.musicPlayer.audioPlayer2.state == .paused{
            YouTubeViewController.musicPlayer.audioPlayer2.pause()
        } else if YouTubeViewController.musicPlayer.audioPlayer2.state == .playing {
            // musicPlayer.audioPlayer2.play()
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
        if YouTubeViewController.musicPlayer.audioPlayer2.state == .paused{
            YouTubeViewController.musicPlayer.audioPlayer2.pause()
        } else if YouTubeViewController.musicPlayer.audioPlayer2.state == .playing {
            // musicPlayer.audioPlayer2.play()
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


extension FavouriteViewController: UISearchResultsUpdating {
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
        //reload()
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
