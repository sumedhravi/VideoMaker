//
//  VideoComposer.swift
//  VideoMaker
//
//  Created by Sumedh Ravi on 14/09/17.
//  Copyright © 2017 Sumedh Ravi. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Photos

class VideoComposer : NSObject {
    var selectedImages : [UIImage] = []
    
    
    
    struct RenderSettings {
        
        var width: CGFloat = 1920  //1280
        var height: CGFloat = 1280 //720
        var fps = 0.5   // 2 frames per second
        var avCodecKey = AVVideoCodecH264
        var videoFilename = "SampleVideo"
        var videoFilenameExt = "mp4"
        
        var size: CGSize {
            return CGSize(width: width, height: height)
        }
        
        var outputURL: URL {
            let fileManager = FileManager.default
            if let tmpDirURL = try? fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
                return tmpDirURL.appendingPathComponent(videoFilename).appendingPathExtension(videoFilenameExt) as URL
            }
            fatalError("URLForDirectory() failed")
        }
    }



    class ImageAnimator {
    
        static let kTimescale: Int32 = 600//    multiple of standard video rates 24, 25, 30, 60 fps
        
        let settings: RenderSettings
        let videoWriter: VideoWriter
        var images: [UIImage]!
        
        var frameNum = 0
        
        class func saveToLibrary(videoURL: URL) {
            PHPhotoLibrary.requestAuthorization { status in
                guard status == .authorized else { return }
                
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL as URL)
                }) { success, error in
                    if !success {
                        print("Could not save video to photo library:", error!)
                    }
                }
            }
        }
        
        class func removeFileAtURL(fileURL: URL) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
            }
            catch _ as NSError {
                
            }
        }
        
        init(renderSettings: RenderSettings,imageArray:[UIImage] ) {
            settings = renderSettings
            videoWriter = VideoWriter(renderSettings: settings)
            images = imageArray
        }
        
        func render(completion: @escaping ()->Void) {
            
            ImageAnimator.removeFileAtURL(fileURL: settings.outputURL)
            
            videoWriter.start()
            videoWriter.render(appendPixelBuffers: appendPixelBuffers) {
            completion()
            }
            
        }
        
        
        //Callback function for VideoWriter.render()
        func appendPixelBuffers(writer: VideoWriter) -> Bool {
            
            let frameDuration = CMTimeMake(Int64(Double(ImageAnimator.kTimescale) / settings.fps), ImageAnimator.kTimescale)
            
            while !images.isEmpty {
                
                if writer.isReadyForData == false {
                    
                    return false
                }
                
                let image = images.removeFirst()
                let presentationTime = CMTimeMultiply(frameDuration, Int32(frameNum))
                let success = videoWriter.addImage(image: image, withPresentationTime: presentationTime)
                if success == false {
                    fatalError("addImage() failed")
                }
                
                frameNum += 1
            }
            
          
            return true
        }
        
    }


    class VideoWriter {
        
        let renderSettings: RenderSettings
        
        var videoWriter: AVAssetWriter!
        var videoWriterInput: AVAssetWriterInput!
        var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor!
        
        var isReadyForData: Bool {
            return videoWriterInput?.isReadyForMoreMediaData ?? false
        }
        
        class func pixelBufferFromImage(image: UIImage, pixelBufferPool: CVPixelBufferPool, size: CGSize) -> CVPixelBuffer {
            
            var pixelBufferOut: CVPixelBuffer?
            
            let status = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pixelBufferPool, &pixelBufferOut)
            if status != kCVReturnSuccess {
                fatalError("CVPixelBufferPoolCreatePixelBuffer() failed")
            }
            
            let pixelBuffer = pixelBufferOut!
            
            CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
            
            let data = CVPixelBufferGetBaseAddress(pixelBuffer)
            let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
                let context = CGContext(data: data, width: Int(size.width), height: Int(size.height),
                                    bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
            
                context!.clear(CGRect(x: 0, y: 0, width: size.width, height: size.height))
            
                let horizontalRatio = size.width / image.size.width
                let verticalRatio = size.height / image.size.height
            //let aspectRatio = max(horizontalRatio, verticalRatio) // ScaleAspectFill
                let aspectRatio = min(horizontalRatio, verticalRatio) // ScaleAspectFit
            
                let newSize = CGSize(width: image.size.width * aspectRatio, height: image.size.height * aspectRatio)
            
            let x = newSize.width < size.width ? (size.width - newSize.width) / 2 : 0
            let y = newSize.height < size.height ? (size.height - newSize.height) / 2 : 0
            context?.draw(image.cgImage!, in: CGRect(x: x, y: y, width: newSize.width, height: newSize.height))
            CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
            return pixelBuffer
        }
        
        init(renderSettings: RenderSettings) {
            self.renderSettings = renderSettings
        }
        
        func start() {
            
            let avOutputSettings: [String: AnyObject] = [
                AVVideoCodecKey: renderSettings.avCodecKey as AnyObject,
                AVVideoWidthKey: NSNumber(value: Float(renderSettings.width)),
                AVVideoHeightKey: NSNumber(value: Float(renderSettings.height))
            ]
            
            func createPixelBufferAdaptor() {
                let sourcePixelBufferAttributesDictionary = [
                    kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32ARGB),
                    kCVPixelBufferWidthKey as String: NSNumber(value: Float(renderSettings.width)),
                    kCVPixelBufferHeightKey as String: NSNumber(value: Float(renderSettings.height))
                ]
                pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput, sourcePixelBufferAttributes: sourcePixelBufferAttributesDictionary)
            }
            
            func createAssetWriter(outputURL: URL) -> AVAssetWriter {
                guard let assetWriter = try? AVAssetWriter(outputURL: outputURL as URL, fileType: AVFileTypeMPEG4) else {
                    fatalError("AVAssetWriter() failed")
                }
                
                guard assetWriter.canApply(outputSettings: avOutputSettings, forMediaType: AVMediaTypeVideo) else {
                    fatalError("canApplyOutputSettings() failed")
                }
                
                return assetWriter
            }
            
            videoWriter = createAssetWriter(outputURL: renderSettings.outputURL)
            videoWriterInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: avOutputSettings)
            
            if videoWriter.canAdd(videoWriterInput) {
                videoWriter.add(videoWriterInput)
            }
            else {
                fatalError("canAddInput() returned false")
            }
            
            // To create Pixel Buffer Adaptor before starting to write
            createPixelBufferAdaptor()
            
            if videoWriter.startWriting() == false {
                fatalError("startWriting() failed")
            }
            
            videoWriter.startSession(atSourceTime: kCMTimeZero)
            
            precondition(pixelBufferAdaptor.pixelBufferPool != nil, "nil pixelBufferPool")
        }
        
        func render(appendPixelBuffers: @escaping (VideoWriter)->Bool, completion: @escaping ()->Void) {
            
            precondition(videoWriter != nil, "Call start() to initialze the writer")
            
            let queue = DispatchQueue(label: "mediaInputQueue")
            videoWriterInput.requestMediaDataWhenReady(on: queue) {
                let isFinished = appendPixelBuffers(self)
                if isFinished {
                    self.videoWriterInput.markAsFinished()
                    self.videoWriter.finishWriting() {
                        DispatchQueue.main.async() {
                            completion()
                        }
                    }
                }
                else {
                    // Fall through. The closure will be called again when the writer is ready.
                }
            }
        }
        
        func addImage(image: UIImage, withPresentationTime presentationTime: CMTime) -> Bool {
            
            precondition(pixelBufferAdaptor != nil, "Call start() to initialze the writer")
            
            let pixelBuffer = VideoWriter.pixelBufferFromImage(image: image, pixelBufferPool: pixelBufferAdaptor.pixelBufferPool!, size: renderSettings.size)
            return pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)
        }
        
    }

}


