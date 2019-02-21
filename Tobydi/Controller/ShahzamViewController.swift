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
import GoogleMobileAds
import Reachability
class ShahzamViewController: UIViewController,UISearchBarDelegate,UISearchControllerDelegate {
    
   
    
    let searchController = UISearchController(searchResultsController: nil)
    var images = [URL]()
    var imagesArrayTubidy = [URL]()
    var searchActive : Bool = false
    var titleArr:[String]=[]
    var video_str=""
    var audioLinks = [String]()
    var myURLString = "https://tubidy.mobi/search.php?q=music"
    var interstitial: GADInterstitial!

    @IBOutlet weak var collectionView: UICollectionView!
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
        callURL()
    }
    
    func callURL()  {
        var searchString = searchController.searchBar.text
        if (searchString?.contains(find: " "))!{
            searchString = searchString?.replace(string: " ", replacement: "+")
        }
        myURLString.removeAll()
        images.removeAll()
        titleArr.removeAll()
        imagesArrayTubidy.removeAll()
        audioLinks.removeAll()
        myURLString = "https://tubidy.mobi/search.php?q=\(searchString ?? "Music")"
        guard let myURL = URL(string: myURLString) else {
            print("Error: \(myURLString) doesn't seem to be a valid URL")
            return
        }
        images = getAudioId(myURL: myURL)
    }
    func getAudioId(myURL: URL) -> [URL] {
        do {
        
            let myHTMLString = try String(contentsOf: myURL, encoding: .ascii)
            let types: NSTextCheckingResult.CheckingType = .link
            
            do {
                let detector = try NSDataDetector(types: types.rawValue)
                
                let matches = detector.matches(in: myHTMLString, options: .reportCompletion, range:  NSMakeRange(0, myHTMLString.characters.count))
                if matches.count > 0 {
                    for (index,match) in matches.enumerated(){
                        let mat = "\(match.url!)"
                        if index > 9 &&  index<22 && mat.contains(find: ".jpg"){
                            if mat.count > 0 {
                                imagesArrayTubidy.append(match.url!)
                            }
                            else{
                                imagesArrayTubidy.append(URL(string:  "https://tubidy.net/nthumbs/1/DdJBluvrj6Gy3CnrsAds2Q_3D_3D.jpg")!)
                            }
                        }
                    }
                }
                for value in imagesArrayTubidy{
                    let aURL = "\(value)"
                    audioLinks.append(aURL[28..<aURL.count-4])
                }
                let stringWithoutHtml = myHTMLString.stripOutHtml()
                let token = stringWithoutHtml?.components(separatedBy: "\n")
                for (index,t) in (token?.enumerated())!{
                    if t.count > 20 && index > 12 && index < 49{
                        var token = t.components(separatedBy: " ")
                        if token.count > 4 {
                            titleArr.append("\(token[0]) \(token[1]) \(token[3]) \(token[4])")
                        }
                        else{
                            titleArr.append(token[0])
                        }
                        
                    }
                }
            } catch {
                print ("error in findAndOpenURL detector")
            }
        } catch let error {
            print("Error: \(error.localizedDescription)")
        }
        SVProgressHUD.dismiss()
        return imagesArrayTubidy
    }
}

extension ShahzamViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return audioLinks.count
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
        item.musicTitle.text = titleArr[indexPath.row]
        item.musicImage.layer.cornerRadius = item.musicImage.frame.width / 2
        item.musicImage.clipsToBounds = true
        item.musicArtist.text = "Shahzam"
        if imagesArrayTubidy.count == audioLinks.count {
             item.musicImage.kf.setImage(with: imagesArrayTubidy[indexPath.row])
        }
        item.backgroundColor = (UIColor(rgb: 0x91dbed))
        return item
    }
    
    func play(url:URL) {
        let playerItem = AVPlayerItem(url: url)
            YouTubeViewController.musicPlayer.player = AVPlayer(playerItem:playerItem)
            // player.volume = 1.0
            YouTubeViewController.musicPlayer.player.play()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        SVProgressHUD.show()
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
        }
        let myURL = URL(string: "https://tubidy.mobi/watch.php?id=\(audioLinks[indexPath.row])&p=3gp-mobile&act=down&lnk=6")
        print( "https://tubidy.mobi/watch.php?id=\(audioLinks[indexPath.row])&p=3gp-mobile&act=down&lnk=6")
        do {
            let myHTMLString = try String(contentsOf: myURL!, encoding: .ascii)
            let types: NSTextCheckingResult.CheckingType = .link
            
            do {
                let detector = try NSDataDetector(types: types.rawValue)
                
                let matches = detector.matches(in: myHTMLString, options: .reportCompletion, range:  NSMakeRange(0, myHTMLString.characters.count))
                if matches.count > 9{
                    self.play(url:matches[11].url!)
                    SVProgressHUD.dismiss()
                }
               
            } catch {
                print ("error in findAndOpenURL detector")
            }
        } catch let error {
            print("Error: \(error.localizedDescription)")
        }
        
    }
    
}

extension ShahzamViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        collectionView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
        //collectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        SVProgressHUD.show(withStatus: "Searching...")
        callURL()
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
