//
//  CompositeVideoViewController.swift
//  VideoMaker
//
//  Created by Sumedh Ravi on 14/09/17.
//  Copyright © 2017 Sumedh Ravi. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Photos

class CompositeVideoViewController: AVPlayerViewController {
    var finalVideoURL = URL(fileURLWithPath: "")
    var playCount = 0
    var cameraUsed = false
    override func viewDidLoad() {
        super.viewDidLoad()
//        let videoPlayer = AVPlayer(url: finalVideoURL)
//        let playerViewController = AVPlayerViewController()
//        playerViewController.player = videoPlayer
        let _ = CustomAlbum.sharedInstance
        self.player = AVPlayer(url: finalVideoURL)
        NotificationCenter.default.addObserver(self , selector: #selector(handleNotification), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
//        self.present(playerViewController, animated: true)
//        do {
            self.player!.play()
//        }
        let newButton = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.done, target: self, action: #selector (saveToLibrary))
        self.navigationItem.rightBarButtonItem = newButton
        let newBackButton = UIBarButtonItem(title: "Home", style: UIBarButtonItemStyle.plain, target: self, action: #selector(goBack))
        self.navigationItem.leftBarButtonItem = newBackButton

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        NotificationCenter.default.addObserver(self , selector: #selector(handleNotification), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
//        NotificationCenter.removeObserver(self)
        
    }
    
    func handleNotification() {
        
        if playCount == 0{
            playCount += 1
            let alert = UIAlertController(title: "",message: "Do you want to save this video to gallery or discard it?",preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Save", style: UIAlertActionStyle.default, handler: {
            (alertAction: UIAlertAction!) in
            self.navigationItem.rightBarButtonItem?.isEnabled = false
                self.saveToLibrary()
                alert.dismiss(animated: true, completion:nil) }))
            alert.addAction(UIAlertAction(title: "Discard", style: UIAlertActionStyle.destructive, handler: {(alertAction: UIAlertAction!) in
                alert.dismiss(animated: true, completion: nil)}))
            present(alert, animated: true, completion: nil)
            return
        }
        else{return}
    }
    
    func saveToLibrary(){
        playCount = 1
        self.navigationItem.rightBarButtonItem?.isEnabled = false
//        PHPhotoLibrary.requestAuthorization { status in
//            guard status == .authorized else { return }
//            
//            PHPhotoLibrary.shared().performChanges({
//                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.finalVideoURL as URL)
//                
//            }) { success, error in
//                if !success {
//                    print("Could not save video to photo library:", error!)
//                }
//                else{
//                        let alert = UIAlertController(title: "",message: "Saved",preferredStyle: .alert)
//                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: {(alertAction: UIAlertAction!) in
//                            alert.dismiss(animated: true, completion: nil)}))
//                        self.present(alert, animated: true, completion: nil)
//                        self.navigationItem.rightBarButtonItem?.isEnabled = false
//
//                    }
//            }
//        }
        CustomAlbum.sharedInstance.save(url: self.finalVideoURL, completion: createAlertVC)
//            let alert = UIAlertController(title: "",message: "Saved",preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: {(alertAction: UIAlertAction!) in
//                                        alert.dismiss(animated: true, completion: nil)}))
//                                    self.present(alert, animated: true, completion: nil)
//                                    self.navigationItem.rightBarButtonItem?.isEnabled = false

        }
    
    
    func goBack(){
        
        if(cameraUsed){
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
        else{
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    
    func createAlertVC(){
        let alert = UIAlertController(title: "",message: "Saved",preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: {(alertAction: UIAlertAction!) in
                                    alert.dismiss(animated: true, completion: nil)}))
                                self.present(alert, animated: true, completion: nil)
    }
}
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

