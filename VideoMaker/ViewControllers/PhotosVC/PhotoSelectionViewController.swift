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
        guard (!selectedImages.isEmpty || !(indexPathsSelected?.isEmpty)!) else{
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

        let newController = self.storyboard?.instantiateViewController(withIdentifier: "photoReorderVC") as! PhotoReorderViewController
        newController.userImages = selectedImages
        navigationController?.pushViewController(newController, animated: true)

    }
    
    var selectedImages : [UIImage]=[]
    var hasReturned : Bool = false
    var userImages : [UIImage] = []
    var permissionGranted = false
    let cellName = "GalleryCollectionViewCell"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
        if permissionGranted{
            getImages()
        }
    
//        getImages()
//        getImages()
//        getImages()
//        getImages()
//        getImages()
//        getImages()
//        getImages()
        
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        if hasReturned{
            galleryView.reloadData()
        }
        
    PHPhotoLibrary.requestAuthorization { (status) in
        switch status{
        case .authorized :
            DispatchQueue.main.async {
                print("User access authorized")
//                if self.hasReturned {
//                    break
//                }
//                self.getImages()
                if !self.permissionGranted && !self.hasReturned{
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


    
    func initialize(){
        galleryView.dataSource = self
        galleryView.delegate = self
        galleryView.allowsSelection = true
        galleryView.allowsMultipleSelection = true
        self.galleryView.register(UINib(nibName: cellName, bundle: nil), forCellWithReuseIdentifier: cellName)
        flowLayoutInitialization()
        

    }
    
    
    @IBAction func cameraButton(_ sender: Any) {
    
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
    
            imagePicker.allowsEditing = false
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.cameraCaptureMode = .photo
            imagePicker.modalPresentationStyle = .fullScreen
            present(imagePicker,animated: true,completion: nil)
        } else {
            noCamera()
        }
    
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        selectedImages.append(chosenImage)
        dismiss(animated: true, completion: nil)
    
}

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }


    func noCamera(){
    print("No Camera")
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
                imageManagerObject.requestImage(for: fetchResults.object(at: i), targetSize:CGSize(width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.height*0.3) , contentMode: .aspectFit , options: requestOptions, resultHandler: {image, error in self.userImages.append(image!)
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


    
  
        
        
        
        //        let imagePicker = UIImagePickerController()
        //        imagePicker.delegate = self

