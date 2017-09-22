//
//  ViewController.swift
//  VideoMaker
//
//  Created by Sumedh Ravi on 13/09/17.
//  Copyright © 2017 Sumedh Ravi. All rights reserved.
//

import UIKit
import Photos

class PhotoSelectionViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var galleryView: UICollectionView!
    
    @IBAction func doneButton(_ sender: UIBarButtonItem) {
        let indexPathsSelected = self.galleryView.indexPathsForSelectedItems
        guard (!cameraImages.isEmpty || !(indexPathsSelected?.isEmpty)!) else{
            let alert = UIAlertController(title: "ALERT",message: "No Images Selected",preferredStyle: .alert)
            present(alert, animated: true, completion: nil)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: {
                (alertAction: UIAlertAction!) in
                alert.dismiss(animated: true, completion:nil) }))
            return
        }
        
        
        for path in indexPathsSelected!{
            selectedImages.append(userImages[path.item])
        }
        totalSelectedImages = selectedImages + cameraImages
        let newController = self.storyboard?.instantiateViewController(withIdentifier: "photoReorderVC") as! PhotoReorderViewController
        newController.userImages = totalSelectedImages
        if(self.cameraUsed){
            newController.cameraUsed = true
        }
        navigationController?.pushViewController(newController, animated: true)

    }
    
    
    @IBOutlet weak var cameraImageView: UIImageView!
    
    var selectedImages: [UIImage]=[]
//    var hasReturnedFromVideo : Bool = false
    var cameraImages: [UIImage] = []
    var totalSelectedImages: [UIImage] = []
    var hasReturnedFromReordering: Bool = false
    var cameraUsed = false
    var userImages: [UIImage] = []
    var permissionGranted = false
    let cellName = "GalleryCollectionViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationController?.isNavigationBarHidden = false
        initialize()
        if permissionGranted{
            getImages()
        }
    

        
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    override func viewDidAppear(_ animated: Bool) {
//        if !selectedImages.isEmpty {
//                selectedImages.removeAll()
//                selectedImages = []
//        }
        
//        if hasReturnedFromVideo{
//            galleryView.reloadData()
//            hasReturnedFromVideo = false
//        }
        if cameraImages.count > 0 && cameraUsed{
            cameraImageView.image = cameraImages[0]
        }
        else{
            cameraImageView.isHidden = true
        }
    PHPhotoLibrary.requestAuthorization { (status) in
        switch status{
        case .authorized :
            DispatchQueue.main.async {
                print("User access authorized")

                if !self.permissionGranted{
                    self.permissionGranted = true
                    self.getImages()
                    self.galleryView.reloadData()
                }}
        case .denied:
            DispatchQueue.main.async {
                print("User access denied")
            let alert = UIAlertController(title: "Alert",message: "Permission to access Photos needs to be granted to select images",preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)

                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: {
                (alertAction: UIAlertAction!) in
                                    alert.dismiss(animated: true, completion: nil)
                    UIApplication.shared.openURL(NSURL(string: UIApplicationOpenSettingsURLString)! as URL)
            
                 }))
            }
            
        case .restricted:
             print("User access is restricted")
            
        case .notDetermined:
             print("User access is not determined")
            
        }
        }
    }


    
   
    @IBAction func deleteCameraImages(_ sender: Any) {
        let alert = UIAlertController(title: "ALERT",message: "Delete Camera Selected Images?",preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: {
            (alertAction: UIAlertAction!) in
            alert.dismiss(animated: true, completion:nil) }))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive , handler: { (alertAction : UIAlertAction!) in
            
            self.cameraImageView.isHidden = true
            self.cameraImageView.image = nil
            self.cameraImages = []
        }))

    }
    
    
    func initialize(){
        galleryView.dataSource = self
        galleryView.delegate = self
        galleryView.allowsSelection = true
        galleryView.allowsMultipleSelection = true
        self.galleryView.register(UINib(nibName: cellName, bundle: nil), forCellWithReuseIdentifier: cellName)
        flowLayoutInitialization()
        

    }
    
    
   
    





    func getImages(){
        let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        myActivityIndicator.center = view.center
        myActivityIndicator.hidesWhenStopped = true
        view.addSubview(myActivityIndicator)

        let imageManagerObject = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        let fetchResults = PHAsset.fetchAssets(with: .image, options: nil)
        if(fetchResults.count>0){
            for i in 0...(fetchResults.count-1){
                imageManagerObject.requestImage(for: fetchResults.object(at: i), targetSize:CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height) , contentMode: .aspectFit , options: requestOptions, resultHandler: {image, error in self.userImages.append(image!)
                })
                
                
            }
        
        }
        myActivityIndicator.stopAnimating()
        return
    }
    
   }


extension PhotoSelectionViewController : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath) as! GalleryCollectionViewCell
        cell.imageView.image = userImages[indexPath.item]
        cell.imageView.contentMode = .scaleAspectFill
        if cell.isSelected{
            
            
            cell.selectionImage.isHidden = false
        }
        else{
            cell.selectionImage.isHidden = true
        }
        
        

        return cell
        
    }
    
}

extension PhotoSelectionViewController : UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)as! GalleryCollectionViewCell
        cell.selectionImage.isHidden = false

    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)as! GalleryCollectionViewCell
        cell.selectionImage.isHidden = true
        
    }
    
    func flowLayoutInitialization(){
        let layout = self.galleryView.collectionViewLayout as? UICollectionViewFlowLayout

        layout?.minimumInteritemSpacing = 1
        layout?.minimumLineSpacing = 1

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {

        return CGSize(width: (UIScreen.main.bounds.width-2)/3 , height: (UIScreen.main.bounds.width-2)/3)
    }

}


    
  
        
        
        

