//
//  ModeSelectionViewController.swift
//  VideoMaker
//
//  Created by Sumedh Ravi on 20/09/17.
//  Copyright © 2017 Sumedh Ravi. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class ModeSelectionViewController: UIViewController {
    
    var cameraSelectedImages : [UIImage] = []
        
    
    @IBOutlet weak var textLabel: UILabel!

    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = true
        
        
//        self.view.layoutIfNeeded()

    }
    

    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(true)
////        self.textLabelLeadConstraint.constant = 0
////        self.textLabelTrailConstraint.constant = 0
////        
////        self.buttonViewLeadConstraint.constant = 30
////        self.buttonViewTrailingConstraint.constant = 30
////        self.view.layoutIfNeeded()
//
//    }
    
    

    @IBAction func cameraButton(_ sender: Any) {
        
//        createCameraVC()
        let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        switch authStatus {
        case .authorized: createCameraVC() // Do your stuff here i.e. callCameraMethod()
        case .denied:             DispatchQueue.main.async {
            print("User access denied")
            let alert = UIAlertController(title: "Alert",message: "Camera access needs to be authorized to click images.",preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: {
                (alertAction: UIAlertAction!) in
                alert.dismiss(animated: true, completion: nil)
                UIApplication.shared.openURL(NSURL(string: UIApplicationOpenSettingsURLString)! as URL)
                
            }))
            }

        case .notDetermined: print("Not Determined")
        default: print("Default")
        
        }
        
    }
    
    
    @IBAction func galleryButton(_ sender: Any) {
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status{
            case .authorized :
                DispatchQueue.main.async {
                    print("User access authorized")
                    
                    self.createGalleryVC()
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
    
    @IBAction func albumButton(_ sender: Any) {
        
    
    }
    
    
    func createGalleryVC(){
        
            let newController = self.storyboard?.instantiateViewController(withIdentifier: "photoSelectionVC") as! PhotoSelectionViewController
            if !self.cameraSelectedImages.isEmpty{
            newController.cameraImages = cameraSelectedImages
                
            }
            self.navigationController?.pushViewController(newController, animated: true)
        
    }
    
    func createCameraVC(){
        
            let newController = self.storyboard?.instantiateViewController(withIdentifier: "CustomCameraViewController") as! CustomCameraViewController
            let cameraNavVC = UINavigationController(rootViewController: newController)
            present(cameraNavVC,animated: true)

        
    }
    
}
    
    

