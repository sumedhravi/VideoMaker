//
//  PhotoReorderViewController.swift
//  VideoMaker
//
//  Created by Sumedh Ravi on 13/09/17.
//  Copyright © 2017 Sumedh Ravi. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class PhotoReorderViewController: UIViewController {
    var userImages: [UIImage] = []
    var videoURL = NSURL(fileURLWithPath: "")
    var audioList = ["Track 0", "Track 1", "Track 2", "Track 3", "Track 4", "Track 5", "Track 6"]
    var audioPlayer = AVAudioPlayer()
    var selectedAudio = NSURL(fileURLWithPath: "")
    var myActivityIndicator: UIActivityIndicatorView!
    var isViewHidden = true
    var watermark :Bool?
    
    @IBOutlet weak var audioCollectionView: UICollectionView!
    @IBOutlet weak var selectedImagesCollectionView: UICollectionView!
    
    
    @IBOutlet weak var buttonConstraint: NSLayoutConstraint!
    
    @IBAction func selectAudioButton(_ sender: UIButton) {
        if isViewHidden{
        UIView.animate(withDuration: 0.6, animations: {
            self.buttonConstraint.constant = 0
            sender.setTitle(">" , for: UIControlState.normal)
            self.view.layoutIfNeeded()
            self.isViewHidden = false

        })
        }
        else {
            UIView.animate(withDuration: 0.6, animations: {
                self.buttonConstraint.constant = UIScreen.main.bounds.width - 48
                sender.setTitle("Audio" , for: UIControlState.normal)
                self.view.layoutIfNeeded()
                self.isViewHidden=true

            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonConstraint.constant = UIScreen.main.bounds.width - 48
        
        configureActivityIndicator()
        configureNavigationItem()
        configureCollectionView()
    }
    override func viewWillDisappear(_ animated: Bool) {
        if !(audioCollectionView.indexPathsForSelectedItems?.isEmpty)!{
            audioPlayer.stop()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func configureActivityIndicator() {
        
        myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        myActivityIndicator.center = view.center
        myActivityIndicator.hidesWhenStopped = true
        view.addSubview(myActivityIndicator)
    }
    
    func configureNavigationItem(){
        navigationItem.title = "Selected Images"
        let newBackButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector (proceed))
        
        self.navigationItem.rightBarButtonItem = newBackButton
        
    }
    
    func configureCollectionView(){
        selectedImagesCollectionView.dataSource = self
        selectedImagesCollectionView.delegate = self
        audioCollectionView.dataSource = self
        audioCollectionView.delegate = self
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongGesture))
        self.selectedImagesCollectionView.addGestureRecognizer(longPressGesture)
        audioCollectionView.register(UINib(nibName: "AudioCollectionViewCell", bundle: nil ), forCellWithReuseIdentifier: "AudioCollectionViewCell")
        audioCollectionView.allowsMultipleSelection = false
        
        flowLayoutInitialization()
    }
    
    func proceed() {
        if (audioCollectionView.indexPathsForSelectedItems?.isEmpty)!{
            let alert = UIAlertController(title: "Alert!",message: "Please Select Audio Track",preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: {(alertAction: UIAlertAction!) in
                alert.dismiss(animated: true, completion: nil)}))
            present(alert, animated: true, completion: nil)
            return
        }
        else{
            audioPlayer.stop()
            myActivityIndicator.startAnimating()
            let settings = VideoComposer.RenderSettings()
            let imageAnimator = VideoComposer.ImageAnimator(renderSettings:settings, imageArray: userImages)
            videoURL = settings.outputURL
            imageAnimator.render(completion: createMerger)
//          let newController = self.storyboard?.instantiateViewController(withIdentifier: "playerVC") as! CompositeVideoViewController
//          newController.finalVideoURL = videoURL as URL
//          navigationController?.pushViewController(newController, animated: true)
        }
    }

    
    
    func createMerger ()->Void {
        let merger = AVMerger()
        merger.mergeFilesWithUrl(videoUrl: videoURL, audioUrl: selectedAudio, watermark: true, completionHandler: { mergedVideoUrl in
            
            if mergedVideoUrl != nil {
                
//                        PHPhotoLibrary.requestAuthorization { status in
//                            guard status == .authorized else { return }
//                
//                            PHPhotoLibrary.shared().performChanges({
//                                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: mergedVideoUrl as! URL)
//                            }) { success, error in
                
                                DispatchQueue.main.async {
                                    self.myActivityIndicator.stopAnimating()
                                    let newController = self.storyboard?.instantiateViewController(withIdentifier: "playerVC") as! CompositeVideoViewController
                                    newController.finalVideoURL = mergedVideoUrl as! URL
                                    self.navigationController?.pushViewController(newController, animated: true)

                                }
                    
//                                if !success {
//                                    print("Could not save video to photo library:", error!)
//                                }
//                            }
//                        }
            }
        })
//        completion()

    }

    
   
//        let newController = self.storyboard?.instantiateViewController(withIdentifier: "") as!
//        newController.userImages = self.sample
//        navigationController?.pushViewController(newController, animated: true)
    
    
    
    
       
       
    func handleLongGesture(gesture: UILongPressGestureRecognizer){
        switch(gesture.state) {
    
        case UIGestureRecognizerState.began:
            guard let selectedIndexPath = self.selectedImagesCollectionView.indexPathForItem(at: gesture.location(in: self.selectedImagesCollectionView)) else {
            break
        }
        selectedImagesCollectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case UIGestureRecognizerState.changed:
            selectedImagesCollectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case UIGestureRecognizerState.ended:
            selectedImagesCollectionView.endInteractiveMovement()
        default:
            selectedImagesCollectionView.cancelInteractiveMovement()
        }
        selectedImagesCollectionView.reloadData()

    
    }
}



extension PhotoReorderViewController:UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == selectedImagesCollectionView{
        return userImages.count
        }
        else {
            return audioList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == selectedImagesCollectionView{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        let view = cell.viewWithTag(1) as? UIImageView
        view?.image = userImages[indexPath.item]
        return cell
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AudioCollectionViewCell", for: indexPath) as! AudioCollectionViewCell
           cell.audioName.text = audioList[indexPath.item]
            if !cell.isSelected{
                cell.isPlaying = false
                cell.cellView.backgroundColor = UIColor(colorLiteralRed: 230, green: 238, blue: 238, alpha: 1)
                cell.cellView.alpha = 0.2
                cell.durationLabel.isHidden = true
            }
            else{
                cell.cellView.backgroundColor = UIColor.black
                cell.durationLabel.isHidden = false
                cell.durationLabel.text = "Duration: \(findDuration(duration: audioPlayer.duration))"

            }
            return cell
        }
        
    }
    
    func findDuration(duration:Double)->String{
        let minutes = Int(duration/60)
        let seconds = Int(duration - Double(minutes)*60)
        return "\(minutes)m:\(seconds)s"
    }
    
}

extension PhotoReorderViewController: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

        if sourceIndexPath.item<destinationIndexPath.item{
            let temp = userImages[sourceIndexPath.item]
            for i in sourceIndexPath.item...destinationIndexPath.item-1{
                userImages[i] = userImages[i+1]
            }
            userImages[destinationIndexPath.item] = temp
        }
        else{
            let temp = userImages[sourceIndexPath.item]
            for i in (destinationIndexPath.item+1...sourceIndexPath.item).reversed(){
                userImages[i] = userImages[i-1]
            }
            userImages[destinationIndexPath.item] = temp
    
        }
        selectedImagesCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == audioCollectionView{
            
            let trackID = indexPath.row
            let path: String! = Bundle.main.resourcePath?.appending("/\(trackID).mp3")
            let mp3URL = NSURL(fileURLWithPath: path)
            selectedAudio = mp3URL
            let cell = audioCollectionView.cellForItem(at: indexPath) as! AudioCollectionViewCell
            //cell.audioImage.layer.cornerRadius = cell.audioImage.getDrawable
            cell.cellView.backgroundColor = UIColor.black
            cell.cellView.alpha = 0.2
            
            if(cell.isPlaying){
                audioPlayer.pause()
                cell.isPlaying = false
            }
            else{
//                if let selectedItems = audioCollectionView.indexPathsForSelectedItems{
//                    
//                }
                do
                {
                    //            if() {
                    //                audioPlayer.pause()
                    //            }
                    //            else{
                    

                    audioPlayer = try AVAudioPlayer(contentsOf: mp3URL as URL)
                    audioPlayer.play()
                    cell.isPlaying = true
                    cell.durationLabel.isHidden = false

                    cell.durationLabel.text = "Duration: \(findDuration(duration: audioPlayer.duration))"

//                    cell.accessoryType = .checkmark
//                    cell.durationLabel.text = "Duration: \(audioPlayer.duration)"
                    
                }
                catch
                {
                    print("An error occurred while trying to extract audio file")
                }}

        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        //audioPlayer.pause()
        if let cell = audioCollectionView.cellForItem(at: indexPath) as! AudioCollectionViewCell?
        {
            cell.isPlaying=false
            cell.durationLabel.isHidden = true
            cell.cellView.backgroundColor = UIColor(colorLiteralRed: 230, green: 238, blue: 238, alpha: 1)
            cell.cellView.alpha = 0.2


        }
    }
    
    func flowLayoutInitialization(){
        let layout = self.selectedImagesCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        
        layout?.minimumInteritemSpacing = 1
        layout?.minimumLineSpacing = 1
        
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == audioCollectionView{
        return UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        }
        return UIEdgeInsets.zero
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        
        if collectionView == selectedImagesCollectionView{
            
        return CGSize(width: (UIScreen.main.bounds.width-2)/3 , height: (UIScreen.main.bounds.width-2)/3)
    
        }
        else{
            return CGSize(width: 120, height: 120)
        }
    }
}



