//
//  ModeSelectionViewController.swift
//  VideoMaker
//
//  Created by Sumedh Ravi on 20/09/17.
//  Copyright © 2017 Sumedh Ravi. All rights reserved.
//

import UIKit

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
        
        createCameraVC()
        
    }
    
    
    @IBAction func galleryButton(_ sender: Any) {
        createGalleryVC()
    
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
    
    

