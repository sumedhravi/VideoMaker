//
//  AlbumViewController.swift
//  VideoMaker
//
//  Created by Sumedh Ravi on 22/09/17.
//  Copyright © 2017 Sumedh Ravi. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Photos

class AlbumViewController: UIViewController {

    var album = PHAssetCollection()
    var videoImageList = [UIImage]()
    var videoDuration : [String] = []
    var photoAssets = PHFetchResult<PHAsset>()
    var player = AVPlayer()
//    let playerViewController = AVPlayerViewController()
    
    @IBOutlet weak var videoCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        videoCollection.dataSource = self
        videoCollection.delegate = self
        videoCollection.register(UINib(nibName: "AlbumCollectionViewCell", bundle: Bundle.main ), forCellWithReuseIdentifier: "AlbumCollectionViewCell")
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", CustomAlbum.albumName)
//        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        if let _: AnyObject = collection.firstObject{
            print("Album found")
            album = collection.firstObject!
            
        }
        photoAssets = PHAsset.fetchAssets(in: album, options: nil)
        let imageManager = PHImageManager.default()
        photoAssets.enumerateObjects({(object: AnyObject!,
            count: Int,
            stop: UnsafeMutablePointer<ObjCBool>) in
            
            if object is PHAsset{
                let asset = object as! PHAsset
                
                
                let imageSize = CGSize(width: asset.pixelWidth,
                                       height: asset.pixelHeight)
                
                let duration = asset.duration

                self.videoDuration.append(self.generateDuration(duration: duration))
                
                
                
                let options = PHImageRequestOptions()
                options.deliveryMode = .highQualityFormat
                options.isSynchronous = true
                
                imageManager.requestImage(for: asset,
                                          targetSize: imageSize,
                                          contentMode: .aspectFill,
                                          options: options,
                                          resultHandler: {
                                            (image, info) -> Void in
                                            self.videoImageList.append(image!)
                                            
                                            
                                            
                })
                
            }
        })

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        navigationItem.title = "My Album"
        

    }
    func generateDuration(duration: TimeInterval) -> String{
        let minutes = Int(duration/60)
        let seconds = Int(duration - Double(minutes)*60)
        return "\(minutes):\(String(format: "%02d", seconds))"
        
    }
}


extension AlbumViewController : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoImageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = videoCollection.dequeueReusableCell(withReuseIdentifier: "AlbumCollectionViewCell", for: indexPath) as! AlbumCollectionViewCell
        cell.videoImage.image = videoImageList[indexPath.row]
        cell.videoDuration.text = videoDuration[indexPath.row]
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        
        return CGSize(width: (UIScreen.main.bounds.width-6)/3 , height: (UIScreen.main.bounds.width-6)/3)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imageManager = PHImageManager.default()
        var videoURL = URL(fileURLWithPath: "")
        let asset = photoAssets[indexPath.row]

        
        imageManager.requestAVAsset(forVideo: asset as PHAsset, options: PHVideoRequestOptions(), resultHandler: {(avAsset, audioMix, info) -> Void in
            if let video = avAsset as? AVURLAsset {
                videoURL = video.url
                 let playerViewController = AVPlayerViewController()
               

                self.player = AVPlayer(url: videoURL)
                playerViewController.player = self.player
                self.present(playerViewController, animated: true) {
                    playerViewController.player!.play()
                }

            }
            
            
        })

    }
    
}
