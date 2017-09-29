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
        DispatchQueue.main.async {
            self.myActivityIndicator.startAnimating()
        }
        
        for path in indexPathsSelected!{
            self.imageManagerObject.requestImage(for: self.fetchResults.object(at: path.item), targetSize:CGSize(width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.height/2 ) , contentMode: .aspectFit , options: self.requestOptions, resultHandler: { image, error in
                
                self.selectedImages.append(image!)
//                self.pushController()
            })
            
        }
        self.pushController()
        
//        totalSelectedImages = selectedImages + cameraImages
//        let newController = self.storyboard?.instantiateViewController(withIdentifier: "photoReorderVC") as! PhotoReorderViewController
//        newController.userImages = totalSelectedImages
//        if(self.cameraUsed){
//            newController.cameraUsed = true
//        }
//        navigationController?.pushViewController(newController, animated: true)
        
    }
    
    
    
    @IBOutlet weak var cameraImageCollection: UICollectionView!
    
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
                        UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)! as URL)
                        
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
        setNavigationBar()

        if cameraImages.count > 0 && cameraUsed{
            cameraView.isHidden = false
            
        }
        else{
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
        
//        if cameraImages.count > 0 && cameraUsed{
//            cameraView.isHidden = false
//            
//        }
//        else{
//            cameraView.isHidden = true
//        }
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
        //                    UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)! as URL)
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
    
    
        
    
    func initialize(){
        galleryView.dataSource = self
        galleryView.delegate = self
        
        cameraImageCollection.dataSource = self
        cameraImageCollection.delegate = self
        cameraImageCollection.layer.borderColor = UIColor(colorLiteralRed: 228/255, green: 228/255, blue: 228/255, alpha: 1).cgColor
        cameraImageCollection.layer.borderWidth = 2

        
        galleryView.allowsSelection = true
        galleryView.allowsMultipleSelection = true
        self.cameraImageCollection.register(UINib(nibName: "CameraCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CameraCollectionViewCell")

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
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
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

    
    func pushController(){
        DispatchQueue.main.async{
            self.myActivityIndicator.stopAnimating()
        }
        totalSelectedImages = selectedImages + cameraImages
        let newController = self.storyboard?.instantiateViewController(withIdentifier: "photoReorderVC") as! PhotoReorderViewController
        newController.userImages = totalSelectedImages
        if(self.cameraUsed){
            newController.cameraUsed = true
        }
        navigationController?.pushViewController(newController, animated: true)
        
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
    func buttonClicked(sender:UIButton){
        let index = sender.tag
        cameraImages.remove(at: index)
        cameraImageCollection.reloadData()
        if cameraImages.count==0 {
            self.cameraView.isHidden = true
            
        }
    }


}



extension PhotoSelectionViewController : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == galleryView{
            return fetchResults.count
        }
        else {
            return cameraImages.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == galleryView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath) as! GalleryCollectionViewCell
            imageManagerObject.requestImage(for: fetchResults.object(at: indexPath.row), targetSize:CGSize(width: UIScreen.main.bounds.width/3, height: UIScreen.main.bounds.height/3) , contentMode: .aspectFit , options: requestOptions, resultHandler: {image, error in
                
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
    
        else{
    
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CameraCollectionViewCell", for: indexPath) as! CameraCollectionViewCell
            cell.cellImage.image = cameraImages[indexPath.item]
            cell.deleteButton.tag = indexPath.item
            cell.deleteButton.addTarget(self, action: #selector(buttonClicked), for: UIControlEvents.touchUpInside)
            return cell

        }
    }
    
}

extension PhotoSelectionViewController : UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == galleryView{
            
            let cell = collectionView.cellForItem(at: indexPath)as! GalleryCollectionViewCell
            cell.selectionImage.isHidden = false
        }
            
        else{
            cameraImages.remove(at: indexPath.item)
            cameraImageCollection.reloadData()
            if cameraImages.count==0 {
                self.cameraView.isHidden = true
            }

        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == galleryView{
            
            let cell = collectionView.cellForItem(at: indexPath)as! GalleryCollectionViewCell
            cell.selectionImage.isHidden = true
        }
        
    }
    
    func flowLayoutInitialization(){
        let layout = self.galleryView.collectionViewLayout as? UICollectionViewFlowLayout
        
        layout?.minimumInteritemSpacing = 1
        layout?.minimumLineSpacing = 1
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        if collectionView == galleryView{
            return CGSize(width: (UIScreen.main.bounds.width-6)/3 , height: (UIScreen.main.bounds.width-6)/3)
        }
        else{
            return CGSize(width: 60, height: 60)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == cameraImageCollection{
            
            return UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        }
        else {
            return UIEdgeInsets(top: 1, left: 2, bottom: 90, right: 2)
        }
    }
    
}








