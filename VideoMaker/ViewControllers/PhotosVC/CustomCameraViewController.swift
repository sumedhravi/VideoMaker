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

    override var prefersStatusBarHidden : Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageCollection.register(UINib(nibName: "CameraCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CameraCollectionViewCell")
        createCamera()
        self.imageCollection.dataSource = self
        self.imageCollection.delegate = self
//        captureButton.layer.cornerRadius = 30
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
        
        
        imageCollection.reloadData()
    }
   
    override func viewWillAppear(_ animated: Bool) {
        self.buttonConstraint.constant = 20
        self.buttonConstraintToCollectionView.constant = 20
        self.switchButtonConstraint.constant = 35
        
        self.navigationController?.isNavigationBarHidden = true

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
    
    @IBOutlet weak var switchButtonConstraint: NSLayoutConstraint!
    
    @IBAction func doneButton(_ sender: Any) {
        for image in capturedImages{
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }, completionHandler: { (success, error) in
                if !success {
                    print("Could not save video to photo library:", error!)
                }
                
            })

        }
        
        let newController = self.storyboard?.instantiateViewController(withIdentifier: "photoSelectionVC") as! PhotoSelectionViewController
        newController.cameraUsed = true
        for image in capturedImages{
            newController.cameraImages.append(image)
        }
        capturedImages = []
//        self.buttonConstraint.constant = 50
//        self.buttonConstraintToCollectionView.constant = 50
        
    

        isInitialized = false
        self.navigationController?.pushViewController(newController, animated: true)

    }

    
    @IBAction func cancelButton(_ sender: Any) {
        if capturedImages.count == 0{
            dismiss(animated: true, completion: nil)
            return
        }
        let alert = UIAlertController(title: "Alert!",message: "Are you sure you want to discard these images?",preferredStyle:.alert)
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default , handler: { (alertAction) in
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Discard", style: UIAlertActionStyle.destructive, handler: {(alertAction: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
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
    
    func buttonClicked(sender: UIButton){
        let index = sender.tag
        let alert = UIAlertController(title: "Delete selected image?",message: "",preferredStyle:.alert)
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: {(alertAction: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
            self.capturedImages.remove(at: index)
            self.imageCollection.reloadData()
            if self.capturedImages.count == 0{
                self.doneButton.isHidden = true
                UIView.animate(withDuration: 0.5) {
                    self.buttonConstraint.constant = 20
                    self.buttonConstraintToCollectionView.constant = 20
                    self.switchButtonConstraint.constant = 35
                    self.view.layoutIfNeeded()
//                    self.isViewHidden = false
                    
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {(alertAction: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
            
        }))
        present(alert, animated: true, completion: nil)
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
        if (self.connection?.isVideoOrientationSupported)! {
            self.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        }

        self.output.captureStillImageAsynchronously(from: self.connection) { buffer, error in
            if let error = error {
                print("Error capturing Image \(error)")
            } else {
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
                var image = UIImage(data: imageData!, scale: UIScreen.main.scale)
                image = self.fixedOrientation(image: image!)
                self.capturedImages.append(image!)
                DispatchQueue.main.async() {
                    self.imageCollection.reloadData()
                }
                
                self.doneButton.isHidden = false
                
                
            }
        }
        if capturedImages.count == 0{
            
            UIView.animate(withDuration: 0.5) {
                self.buttonConstraint.constant = 100
                self.buttonConstraintToCollectionView.constant = 15
                self.switchButtonConstraint.constant = 115
                self.view.layoutIfNeeded()
                //                    self.isViewHidden = false
                
            }
        }
        
    }
    
//    func rotated() {
//        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
//            if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft{
//                videoPreviewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.landscapeRight
//            }
//            else
//            {
//                videoPreviewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.landscapeLeft
//                
//            }
//        }
//        
//        if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
//            if UIDevice.current.orientation == UIDeviceOrientation.portrait{
//                
//                videoPreviewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.portrait
//            }
//            else
//            {
//                videoPreviewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.portraitUpsideDown
//                
//            }
//        }
//        
//    }
    
    
    func fixedOrientation(image:UIImage) -> UIImage
    {
        if image.imageOrientation == .up {
            return image
        }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        switch image.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: image.size.width, y: image.size.height)
            transform = transform.rotated(by: CGFloat.pi)
            break
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: image.size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2.0)
            break
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: image.size.height)
            transform = transform.rotated(by: CGFloat.pi / -2.0)
            break
        case .up, .upMirrored:
            break
        }
        switch image.imageOrientation {
        case .upMirrored, .downMirrored:
            transform.translatedBy(x: image.size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            break
        case .leftMirrored, .rightMirrored:
            transform.translatedBy(x: image.size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        }
        
        let ctx: CGContext = CGContext(data: nil, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: image.cgImage!.bitsPerComponent, bytesPerRow: 0, space: image.cgImage!.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        
        ctx.concatenate(transform)
        
        switch image.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.height, height: image.size.width))
        default:
            ctx.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
            break
        }
        
        return UIImage(cgImage: ctx.makeImage()!)
    }
    
    
}

extension CustomCameraViewController: UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return capturedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CameraCollectionViewCell", for: indexPath) as! CameraCollectionViewCell
        cell.cellImage.image = capturedImages[indexPath.item]
        cell.deleteButton.tag = indexPath.item
        cell.deleteButton.addTarget(self, action: #selector(buttonClicked), for: UIControlEvents.touchUpInside)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 10, left: 5, bottom: 5, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: 70, height: 70)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("here")
    }
    
}
