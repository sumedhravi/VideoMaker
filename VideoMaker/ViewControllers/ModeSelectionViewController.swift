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
    var gradientLayer: CAGradientLayer!
//    var navGradientLayer: CAGradientLayer!
    

    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createGradientLayer()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setNavigationBar()
//        UIApplication.shared.statusBarStyle = .default
//        createGradientLayer()
        
//        self.view.layoutIfNeeded()

    }
    
//    override func viewDidLayoutSubviews() {
//        
//        super.viewDidLayoutSubviews()
//        self.gradientLayer.frame = self.view.bounds
//        self.gradientLayer.position = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
//
//    }
    

    
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
        case .denied:
            DispatchQueue.main.async {
                print("User access denied")
                let alert = UIAlertController(title: "Alert",message: "Camera access needs to be authorized to click images.",preferredStyle: .alert)
                self.present(alert, animated: true, completion: nil)
            
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: {
                (alertAction: UIAlertAction!) in
                    alert.dismiss(animated: true, completion: nil)
                    UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)! as URL)
                
                }))
            }

        case .notDetermined:
            
             print("Not Determined")
            
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { granted in
                if granted {
                    print("Granted access to \(AVMediaTypeVideo)")
                    self.createCameraVC()
                } else {
                    print("Denied access to \(AVMediaTypeVideo)")
                    DispatchQueue.main.async {
                        print("User access denied")
                        let alert = UIAlertController(title: "Alert",message: "Camera access needs to be authorized to click images.",preferredStyle: .alert)
                        self.present(alert, animated: true, completion: nil)
                        
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: {
                            (alertAction: UIAlertAction!) in
                            alert.dismiss(animated: true, completion: nil)
                            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)! as URL)
                            
                        }))
                    }

                    
                }
            }
            
            
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
    
    @IBAction func albumButton(_ sender: Any) {
        let newController = self.storyboard?.instantiateViewController(withIdentifier: "AlbumViewController") as! AlbumViewController
        self.navigationController?.pushViewController(newController, animated: true)
    
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
    
    func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.view.layer.bounds
        
        gradientLayer.colors = [UIColor(colorLiteralRed: 80/255, green: 201/255, blue: 195/255, alpha: 100 ).cgColor, UIColor(colorLiteralRed: 150/255, green: 222/255, blue: 218/255, alpha: 100).cgColor ]
        self.view.layer.insertSublayer(gradientLayer, at: 0)

//        self.view.layer.addSublayer(gradientLayer)
    }
    
    
    func setNavigationBar(){
        let navGradientLayer = CAGradientLayer()
        self.navigationController?.isNavigationBarHidden = true
        navGradientLayer.frame = CGRect(x: 0, y: -20, width: UIApplication.shared.statusBarFrame.width, height: UIApplication.shared.statusBarFrame.height + (navigationController?.navigationBar.frame.height)!)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        navGradientLayer.colors = [UIColor(colorLiteralRed: 80/255, green: 201/255, blue: 195/255, alpha: 100 ).cgColor, UIColor(colorLiteralRed: 150/255, green: 222/255, blue: 218/255, alpha: 100).cgColor ]
        self.navigationController?.navigationBar.setBackgroundImage(image(fromLayer: navGradientLayer), for: UIBarMetrics.default)
    }
    
    func image(fromLayer layer: CALayer) -> UIImage {
        UIGraphicsBeginImageContext(layer.frame.size)
        
        layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return outputImage!
    }
}
    
    

