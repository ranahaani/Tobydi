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
import SVProgressHUD
class YouTubeViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
     let audioPlayer = STKAudioPlayer()
    private var player: AVPlayer!

    @IBOutlet weak var Songtitle: UILabel!
    @IBOutlet weak var videoView: UIView!
    var rows=0
    var arr:[String]=[]
    var video_arr:[String]=[]
    var video_str=""
    var images:[String]=[]
    var isPlaying = false
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.setForegroundColor(UIColor(rgb: 0x91dbed))
       SVProgressHUD.show()
        Songtitle.textColor = (UIColor(rgb: 0x91dbed))
        view.backgroundColor = (UIColor(rgb: 0x91dbed))
        reload()
    }

    func do_table_refresh()
    {
        DispatchQueue.main.async{
            self.loadView()
            
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
        let delimiter = " "
        let newstr = arr[indexPath.row]
        let token = newstr.components(separatedBy: delimiter)
        item.musicTitle.text = token[0] + " " + token[1]
        item.musicImage.layer.cornerRadius = item.musicImage.frame.width / 2
        item.Button.layer.cornerRadius = item.Button.frame.width / 2
        
        
        item.Button.animateButtonUp()
        item.Button.clipsToBounds = true
        item.musicImage.clipsToBounds = true
        if isPlayings()==false{
            item.Button.setBackgroundImage(UIImage(named: "PlayFilled"), for: .normal)
        }else{
            item.Button.setBackgroundImage(UIImage(named: "PauseFilled"), for: .normal)
        }
       item.musicArtist.text = "YouTube"
        item.musicImage.kf.setImage(with: URL(string: images[indexPath.row]))
        item.backgroundColor = (UIColor(rgb: 0x91dbed))
        return item
    }
    
    
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Clicked")
        
        let y = YoutubeDirectLinkExtractor()
        y.extractInfo(for: .id(video_arr[indexPath.row]), success: { info in
            
           // print()
            if self.isPlayings() == false {
                if info.highestQualityPlayableLink == nil{
                    if info.lowestQualityPlayableLink == nil{
                        let alertVC = UIAlertController(title: "Error", message: info.lowestQualityPlayableLink, preferredStyle: .alert)
                        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                        alertVC.addAction(action)
                        self.present(alertVC,animated: true)
                    }
                    else{
                        SVProgressHUD.setStatus("Started")
                            self.audioPlayer.play(info.lowestQualityPlayableLink!)
                        print("Playing")

                    }
                    
                }
                else
                {
                    SVProgressHUD.setStatus("Started")

                    self.audioPlayer.play(info.highestQualityPlayableLink!)
                }
                self.isPlaying = true
                
            }
            else if self.isPlayings() == true {
                print("Paused")
                self.audioPlayer.pause()
                self.isPlaying = false
            }
            else {
                self.audioPlayer.stop()
            }
            self.Songtitle.text = self.arr[indexPath.row]
           
        }) { error in
            print(error)
        }
    }

    private func isPlayings() -> Bool {
        return audioPlayer.progress != 0
    }
    func reload() {
        let jsonUrlString =
        "https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=50&q=Hollywood+Music&key=AIzaSyCSP3HUsmcAPSnUAS877Jac9QzDABnH6NY"
        
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
extension UIView {
    
    func animateButtonDown() {
        
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction, .curveEaseIn], animations: {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: nil)
    }
    
    func animateButtonUp() {
        
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
}
extension UIImage {
    func image(alpha: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: .zero, blendMode: .normal, alpha: alpha)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
