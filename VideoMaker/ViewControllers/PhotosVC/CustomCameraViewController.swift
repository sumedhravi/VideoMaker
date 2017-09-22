//
//  CustomCameraViewController.swift
//  VideoMaker
//
//  Created by Sumedh Ravi on 20/09/17.
//  Copyright © 2017 Sumedh Ravi. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class CustomCameraViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageCollection.register(UINib(nibName: "CameraCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CameraCollectionViewCell")
        self.createCamera()
        self.imageCollection.dataSource = self
        self.imageCollection.delegate = self
        captureButton.layer.cornerRadius = 30
        captureButton.clipsToBounds = true
        self.navigationController?.isNavigationBarHidden = true

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.videoPreviewLayer.bounds = self.videoCaptureView.bounds
        self.videoPreviewLayer.position = CGPoint(x: self.videoCaptureView.bounds.midX, y: self.videoCaptureView.bounds.midY)
        if capturedImages.count==0 {
            doneButton.isHidden = true
        }
        else{
            doneButton.isHidden = false
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        imageCollection.reloadData()
    }
   
    
    @IBOutlet weak var videoCaptureView: UIView!
    
    @IBOutlet weak var captureButton: UIButton!

    @IBAction func captureButton(_ sender: Any) {
        UIView.animate(withDuration: 0.4, animations: {
            self.captureButton.alpha=0.2
            self.view.layoutIfNeeded()
        })
        UIView.animate(withDuration: 0.4, animations:
            {
                self.captureButton.alpha=1
                self.view.layoutIfNeeded()
                
        })
        
        self.takePhoto()
    }
    
    
    @IBOutlet weak var menuView: UIView!
    
    @IBOutlet weak var doneButton: UIButton!
    
    
    @IBAction func doneButton(_ sender: Any) {
         let newController = self.storyboard?.instantiateViewController(withIdentifier: "photoSelectionVC") as! PhotoSelectionViewController
        newController.cameraUsed = true
        for image in capturedImages{
            newController.cameraImages.append(image)
        }
        capturedImages = []
        isInitialized = false
        self.navigationController?.pushViewController(newController, animated: true)

    }

    
    @IBAction func cancelButton(_ sender: Any) {
        if capturedImages.count == 0{
            dismiss(animated: true, completion: nil)
            return
        }
        let alert = UIAlertController(title: "Alert!",message: "Are you sure you want to discard these images?",preferredStyle:.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.destructive, handler: {(alertAction: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default , handler: { (alertAction) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)
        return
    }
        
       
    
    @IBAction func switchButton(_ sender: Any) {
        captureSession.stopRunning()
        
        if camera == .back{
            self.camera = .front
        }
        
        else{
            self.camera = .back
        }
        self.createCamera()

    }

    @IBOutlet weak var switchButton: UIButton!
    
    @IBOutlet weak var bottomView: UIVisualEffectView!
    
    @IBOutlet weak var imageCollection: UICollectionView!

    
    @IBOutlet weak var buttonConstraintToCollectionView: NSLayoutConstraint!

    
    @IBOutlet weak var buttonConstraint: NSLayoutConstraint!


    var connection: AVCaptureConnection?
    var output : AVCaptureStillImageOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var inputDevice: AVCaptureDeviceInput?
    var captureSession: AVCaptureSession!
    var capturedImages: [UIImage] = []
    var isInitialized: Bool = false
    var cameraDevice: AVCaptureDevice?
    enum CameraType {
        case front
        case back
    }
    var camera = CameraType.back
    
    
    @IBAction func zoomFunction(_ sender: UIPinchGestureRecognizer) {
        guard let device = cameraDevice else { return }
        if sender.state == .changed {
            
            let maxZoomFactor = device.activeFormat.videoMaxZoomFactor/20
            let pinchVelocityDividerFactor: CGFloat = 5.0
            
            do {
                
                try device.lockForConfiguration()
                defer { device.unlockForConfiguration() }
                
                let desiredZoomFactor = device.videoZoomFactor + atan2(sender.velocity, pinchVelocityDividerFactor)
                device.videoZoomFactor = max(1.0, min(desiredZoomFactor, maxZoomFactor))
                
            } catch {
                print(error)
            }
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

}


extension CustomCameraViewController{
    func createCamera() {
        if captureSession == nil{
            self.captureSession = AVCaptureSession()
            if captureSession.canSetSessionPreset(AVCaptureSessionPresetHigh) {
                captureSession.sessionPreset = AVCaptureSessionPresetHigh
            } else {
                print("Error: Couldn't set preset = (AVCaptureSessionPresetHigh)")
                return
                
            }
            
        }
        //        var cameraDevice: AVCaptureDevice?
        for input : AVCaptureDeviceInput in (self.captureSession.inputs as! [AVCaptureDeviceInput]){
            self.captureSession.removeInput(input)
        }
        for output in self.captureSession.outputs {
            self.captureSession.removeOutput(output as! AVCaptureOutput)
        }
        
        
        if (camera == .front) {
            let videoDevices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
            
            
            for device in videoDevices!{
                let device = device as! AVCaptureDevice
                if device.position == AVCaptureDevicePosition.front {
                    cameraDevice = device
                    break
                }
            }
        }
        else {
            cameraDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        }
        
        
        do {
            inputDevice = try AVCaptureDeviceInput(device: cameraDevice)
        }
        catch
        { return }
        if captureSession.canAddInput(inputDevice) {
            captureSession.addInput(inputDevice)
        }
        else {
            print("Error: Couldn't add input device")
            return
        }
        
        let imageOutput = AVCaptureStillImageOutput()
        if captureSession.canAddOutput(imageOutput) {
            captureSession.addOutput(imageOutput)
        }
        else {
            print("Error: Couldn't add output")
            return
        }
        self.output = imageOutput
        
        
        let connection = output.connections.first as! AVCaptureConnection!
        
        self.connection = connection!
        connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        
        captureSession.startRunning()
        
        if(!isInitialized){
            let videoLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoLayer?.contentsScale = UIScreen.main.scale
            
            self.videoCaptureView.layer.addSublayer(videoLayer!)
            
            
            self.videoPreviewLayer = videoLayer
            
            
//            captureButton.backgroundColor = UIColor.red
            self.videoCaptureView.layer.addSublayer(captureButton.layer)
            self.videoCaptureView.addSubview(menuView)
            self.videoCaptureView.addSubview(switchButton)
            self.videoCaptureView.addSubview(bottomView)
            self.isInitialized = true
        }
        
    }
    
    
    func takePhoto() {
        self.output.captureStillImageAsynchronously(from: self.connection) { buffer, error in
            if let error = error {
                print("Error capturing Image \(error)")
            } else {
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
                let image = UIImage(data: imageData!, scale: UIScreen.main.scale)
                self.capturedImages.append(image!)
                DispatchQueue.main.async() {
                    self.imageCollection.reloadData()
                }
                
                self.doneButton.isHidden = false
                
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: image!)
                }, completionHandler: { (success, error) in
                    if !success {
                        print("Could not save video to photo library:", error!)
                    }
                    
                })
                
            }
        }
        if capturedImages.count == 0{
            
            UIView.animate(withDuration: 0.5) {
                self.buttonConstraint.constant = 100
                self.buttonConstraintToCollectionView.constant = 15
                self.view.layoutIfNeeded()
                //                    self.isViewHidden = false
                
            }
        }
        
    }
    
    
}

extension CustomCameraViewController: UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return capturedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CameraCollectionViewCell", for: indexPath) as! CameraCollectionViewCell
        cell.cellImage.image = capturedImages[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: 75, height: 75)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delete selected image?",message: "",preferredStyle:.alert)
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: {(alertAction: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
            self.capturedImages.remove(at: indexPath.item)
            self.imageCollection.reloadData()
            
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {(alertAction: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
            
        }))
        present(alert, animated: true, completion: nil)
    }
    
}