//
//  iTunesViewController.swift
//  Tobydi
//
//  Created by Muhammad Abdullah on 17/01/2019.
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
import Reachability
class iTunesViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    let player = FRadioPlayer.shared
    var isSame = false
    
    let reachability = Reachability()!
    var audioPlayer = STKAudioPlayer()
    
    @IBOutlet weak var Songtitle: MarqueeLabel!
    @IBOutlet weak var videoView: UIView!
    var trackURL:[String]=[]
    var trackArtist:[String]=[]
    var trackImages:[String]=[]
    var trackName:[String]=[]
    override func viewDidLoad() {
        

        super.viewDidLoad()
        SVProgressHUD.setForegroundColor(UIColor(rgb: 0x91dbed))
        SVProgressHUD.show()
        Songtitle.textColor = (UIColor(rgb: 0x91dbed))
        view.backgroundColor = (UIColor(rgb: 0x91dbed))
        reload()
        player.artworkSize = 100
        player.enableArtwork = true
        
        
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
        Songtitle.text = trackName[indexPath.row]
        if player.isPlaying && isSame == false{
            player.pause()
            isSame = true
            SVProgressHUD.show(UIImage(named: "PauseFilled") ?? UIImage(named:"play-button")!, status: "Paused")
            
            
        }
        else if player.isPlaying && isSame == true {
            player.play()
            isSame = false
            SVProgressHUD.show(UIImage(named: "PlayFilled") ?? UIImage(named:"play-button")!, status: "Played")
        }
        else{
            player.radioURL = URL(string: trackURL[indexPath.row])
            isSame = false
            SVProgressHUD.show(UIImage(named: "PlayFilled") ?? UIImage(named:"play-button")!, status: "Played")
        }
    }
    
    
    func reload() {
        let jsonUrlString =
        "https://itunes.apple.com/search?term=Queen&entity=song&limit=300"
        
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
