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
import AudioPlayer
import YoutubeDirectLinkExtractor
import StreamingKit

class YouTubeViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    
    private var player: AVPlayer!

    @IBOutlet weak var videoView: UIView!
    var rows=0
    var arr:[String]=[]
    var video_arr:[String]=[]
    var video_str=""
    var images:[String]=[]
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        // Do any additional setup after loading the view, typically from a nib.
        reload()
    }

    func do_table_refresh()
    {
        DispatchQueue.main.async{
            self.loadView()
            //self.get_youtube_link(videoID: self.video_arr[0])
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: "item", for: indexPath) as! PlayerCollectionViewCell
        item.musicTitle.text = arr[indexPath.row]
        item.musicImage.layer.cornerRadius = item.musicImage.frame.width / 2
        item.musicImage.clipsToBounds = true
        //item.PlayButton.addTarget(self, action: #selector(buttonAction(withSender: self)), for: .touchUpInside)
       // item.musicArtist.text = "Aman"
        item.musicImage.kf.setImage(with: URL(string: images[indexPath.row]))
        return item
    }
    
    
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let y = YoutubeDirectLinkExtractor()
        
        y.extractInfo(for: .id(video_arr[indexPath.row]), success: { info in
            let player = AVPlayer(url: URL(string: info.highestQualityPlayableLink!)!)
            let playerViewController = MusicPlayerController()
            playerViewController.player = player
            
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        }) { error in
            print(error)
        }
        
    }

    
    
    func reload() {
        let jsonUrlString =
        "https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=120&q=Music&key=AIzaSyCSP3HUsmcAPSnUAS877Jac9QzDABnH6NY"
        
        let url = URL(string: jsonUrlString)
        
        URLSession.shared.dataTask(with: url!) { (data, response, err) in
            guard let data = data else { return }
            
            do {
                
                let songs = try JSONDecoder().decode(yt.self, from: data)
                for sng in songs.items {
                    if(sng.id.videoId==nil){
                        
                    }else{
                        self.video_arr.append(sng.id.videoId)
                        self.images.append(sng.snippet.thumbnails.high.url)
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

