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
import FRadioPlayer
import YoutubeDirectLinkExtractor
import StreamingKit
import SVProgressHUD
import MarqueeLabel
import GoogleMobileAds
import HCYoutubeParser
import Reachability
class ShahzamViewController: UIViewController,UISearchBarDelegate,UISearchControllerDelegate {
    let searchController = UISearchController(searchResultsController: nil)
    var images = [URL]()

    var searchActive : Bool = false
    var video_arr:[String]=[]
    var video_str=""
    var audioLinks = [String]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        let myURLString = "https://tubidy.mobi/search.php?q=music"
        guard let myURL = URL(string: myURLString) else {
            print("Error: \(myURLString) doesn't seem to be a valid URL")
            return
        }
        images = getAudioId(myURL: myURL)
    }
    func getAudioId(myURL: URL) -> [URL] {
        var imagesArrayTubidy = [URL]()
        
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
                            imagesArrayTubidy.append(match.url!)
                            
                        }
                    }
                }
                for value in imagesArrayTubidy{
                    let aURL = "\(value)"
                    audioLinks.append(aURL)
                }
                
                
                
            } catch {
                print ("error in findAndOpenURL detector")
            }
        } catch let error {
            print("Error: \(error.localizedDescription)")
        }
        
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
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: "item", for: indexPath) as! PlayerCollectionViewCell
        collectionView.backgroundColor = (UIColor(rgb: 0x91dbed))
        let token = audioLinks[indexPath.row].components(separatedBy: " ")
        if token.count >= 2{
            item.musicTitle.text = token[0] + " " + token[1]
        }
        else{
            item.musicTitle.text = token[0]
        }
        item.musicImage.layer.cornerRadius = item.musicImage.frame.width / 2
        item.musicImage.clipsToBounds = true
        item.musicArtist.text = "Shahzam"
        item.musicImage.kf.setImage(with: images[indexPath.row])
        item.backgroundColor = (UIColor(rgb: 0x91dbed))
        return item
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
}

extension ShahzamViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        //collectionView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
        collectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        SVProgressHUD.show(withStatus: "Searching...")
        collectionView.reloadData()
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        if !searchActive {
            searchActive = true
           // collectionView.reloadData()
        }
        
        searchController.searchBar.resignFirstResponder()
    }
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
}
