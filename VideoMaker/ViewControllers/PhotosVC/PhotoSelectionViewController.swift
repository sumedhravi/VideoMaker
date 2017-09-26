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
        
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        
        for path in indexPathsSelected!{
            imageManagerObject.requestImage(for: fetchResults.object(at: path.item), targetSize:PHImageManagerMaximumSize , contentMode: .aspectFit , options: requestOptions, resultHandler: {image, error in
                
                self.selectedImages.append(image!)
                
            })

            
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
    
    @IBOutlet weak var cameraView: UIView!
    
    var selectedImages: [UIImage]=[]
    //    var hasReturnedFromVideo : Bool = false
    var cameraImages: [UIImage] = []
    var totalSelectedImages: [UIImage] = []
    var hasReturnedFromReordering: Bool = false
    var cameraUsed = false
    var userImages: [UIImage] = []
    var permissionGranted = false
    let cellName = "GalleryCollectionViewCell"
    let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    let requestOptions = PHImageRequestOptions()
    var imageManagerObject = PHImageManager.init()
    var fetchResults = PHFetchResult<PHAsset> ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status{
            case .authorized :
                print("User access authorized")
                self.imageManagerObject = PHImageManager.default()
                if !self.permissionGranted{
                    self.permissionGranted = true
                    self.getImages()
                }
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        

        if cameraImages.count == 0{
            cameraView.isHidden = true
        }
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
        setNavigationBar()
        if cameraImages.count > 0 && cameraUsed{
            cameraImageView.image = cameraImages[0]
        }
        else{
            cameraImageView.isHidden = true
        }
        //    PHPhotoLibrary.requestAuthorization { (status) in
        //        switch status{
        //        case .authorized :
        //            DispatchQueue.main.sync {
        //                print("User access authorized")
        //
        //                if !self.permissionGranted{
        //                    self.permissionGranted = true
        //                    self.getImages()
        //                    self.galleryView.reloadData()
        //                }
        ////            self.myActivityIndicator.stopAnimating()
        //            }
        //        case .denied:
        //            DispatchQueue.main.async {
        //                print("User access denied")
        //            let alert = UIAlertController(title: "Alert",message: "Permission to access Photos needs to be granted to select images",preferredStyle: .alert)
        //            self.present(alert, animated: true, completion: nil)
        //
        //                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: {
        //                (alertAction: UIAlertAction!) in
        //                                    alert.dismiss(animated: true, completion: nil)
        //                    UIApplication.shared.openURL(NSURL(string: UIApplicationOpenSettingsURLString)! as URL)
        //
        //                 }))
        //            }
        //
        //        case .restricted:
        //             print("User access is restricted")
        //
        //        case .notDetermined:
        //             print("User access is not determined")
        //
        //        }
        //        }
        
        //        if permissionGranted{
        //            getImages()
        //        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        self.selectedImages.removeAll()
        self.selectedImages = []

    }
    
    
    
    @IBAction func deleteCameraImages(_ sender: Any) {
        let alert = UIAlertController(title: "ALERT",message: "Delete Camera Selected Images?",preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: {
            (alertAction: UIAlertAction!) in
            alert.dismiss(animated: true, completion:nil) }))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive , handler: { (alertAction : UIAlertAction!) in
            
            self.cameraView.isHidden = true
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
        myActivityIndicator.center = view.center
        myActivityIndicator.hidesWhenStopped = true
        view.addSubview(myActivityIndicator)
//        self.navigationController?.navigationBar.barTintColor = UIColor(colorLiteralRed: 80/255, green: 201/255, blue: 195/255, alpha: 0.9)
        
        
    }
    
    
    
    func setNavigationBar(){
        let navGradientLayer = CAGradientLayer()
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.tintColor = UIColor.white

        navGradientLayer.frame = CGRect(x: 0, y: -20, width: UIApplication.shared.statusBarFrame.width, height: UIApplication.shared.statusBarFrame.height + (navigationController?.navigationBar.frame.height)!)
        
        navGradientLayer.colors = [UIColor(colorLiteralRed: 80/255, green: 201/255, blue: 195/255, alpha: 100 ).cgColor, UIColor(colorLiteralRed: 150/255, green: 222/255, blue: 218/255, alpha: 100).cgColor]
        self.navigationController?.navigationBar.setBackgroundImage(image(fromLayer: navGradientLayer), for: UIBarMetrics.default)
    }
    
    func image(fromLayer layer: CALayer) -> UIImage {
        UIGraphicsBeginImageContext(layer.frame.size)
        
        layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return outputImage!
    }

    
    
    
    
    
    func getImages(){
        
            self.myActivityIndicator.startAnimating()
        
//        myActivityIndicator.startAnimating()
        
//        let imageManagerObject = PHImageManager.default()
//        let requestOptions = PHImageRequestOptions()
        fetchResults = PHAsset.fetchAssets(with: .image, options: nil)
        
        DispatchQueue.main.async {
            self.galleryView.reloadData()
            self.myActivityIndicator.stopAnimating()
        }
        
//        if(fetchResults.count>0) {
//            for i in 0...(fetchResults.count-1) {
//                imageManagerObject.requestImage(for: fetchResults.object(at: i), targetSize:CGSize(width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.height/2) , contentMode: .aspectFit , options: requestOptions, resultHandler: {image, error in
//                    
//                    self.userImages.append(image!)
//                })
//                
//                
//            }
//            
//        }
    }
}



extension PhotoSelectionViewController : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath) as! GalleryCollectionViewCell
        imageManagerObject.requestImage(for: fetchResults.object(at: indexPath.row), targetSize:CGSize(width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.height/2) , contentMode: .aspectFit , options: requestOptions, resultHandler: {image, error in
            
                cell.imageView.image = image
                cell.imageView.contentMode = .scaleAspectFill
            
        })

        
        
//        cell.imageView.image = userImages[indexPath.item]
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
        
        return CGSize(width: (UIScreen.main.bounds.width-4)/3 , height: (UIScreen.main.bounds.width-4)/3)
    }
    
}








