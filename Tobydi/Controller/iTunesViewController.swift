//
//  iTunesViewController.swift
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
class iTunesViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource ,UISearchBarDelegate,UISearchControllerDelegate{
    var isSame = false
    @IBOutlet weak var collectionView: UICollectionView!
    let reachability = Reachability()!
    var interstitial: GADInterstitial!

    @IBOutlet weak var Songtitle: UILabel!
    @IBOutlet weak var videoView: UIView!
    var trackURL:[String]=[]
    var trackArtist:[String]=[]
    var trackImages:[String]=[]
    var trackName:[String]=[]
    var searchActive : Bool = false
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-4401604271141178/8098469764")
        let request = GADRequest()
        interstitial.load(request)
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
        Songtitle.textColor = (UIColor(rgb: 0x91dbed))
        view.backgroundColor = (UIColor(rgb: 0x91dbed))
        reload()
       
        
        
    }
  
    func play(url:URL) {
        
        do {
            
            let playerItem = AVPlayerItem(url: url)
            
            YouTubeViewController.musicPlayer.player = try AVPlayer(playerItem:playerItem)
            // player.volume = 1.0
            YouTubeViewController.musicPlayer.player.play()
        }
        catch {
            print("AVAudioPlayer init failed")
        }
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
        item.musicImage.layer.cornerRadius = item.musicImage.frame.width / 2
        item.musicImage.clipsToBounds = true
        item.musicArtist.text = trackArtist[indexPath.row]
        item.musicImage.kf.setImage(with: URL(string: trackImages[indexPath.row]))
        item.backgroundColor = (UIColor(rgb: 0x91dbed))
        return item
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
        }
        self.play(url: URL(string:trackURL[indexPath.row])!)
        
        
    }
    
    
    func reload() {
        trackURL.removeAll()
        trackImages.removeAll()
        trackName.removeAll()
        trackArtist.removeAll()
        var searchString = searchController.searchBar.text
        if (searchString?.contains(find: " "))!{
            searchString = searchString?.replace(string: " ", replacement: "+")
        }
        let jsonUrlString =
        "https://itunes.apple.com/search?term=\(searchString ?? "Justin")+Songs&entity=song&limit=50"
        let url = URL(string: jsonUrlString)
        URLSession.shared.dataTask(with: url!) { (data, response, err) in
            guard let data = data else { return }
            
            do {
                
                let songs = try JSONDecoder().decode(iTunes.self, from: data)
                for sng in songs.results {
                    if(sng.previewUrl==nil || sng.artistName == nil || sng.artworkUrl100 == nil || sng.artistName == nil){
                       
                    }else{
                        self.trackName.append(sng.trackName!)
                        self.trackURL.append(sng.previewUrl!)
                        self.trackImages.append(sng.artworkUrl100!)
                        self.trackArtist.append(sng.artistName!)
                    }
                }
                self.do_table_refresh()
                
            } catch let jsonErr {
                print("Error serializing json:", jsonErr)
            }
            
            }.resume()
        
    }

}
extension iTunesViewController: UISearchResultsUpdating {
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
