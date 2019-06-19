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
        
        
        getDataFromApi()
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
              jsonUrlString = "https://api.audioboom.com/audio_clips?find[query]=Justin%20Bieber"
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
        //SVProgressHUD.setSuccessImage(UIImage(named: "PlayFilled")!)
        SVProgressHUD.showSuccess(withStatus: "Played")

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
