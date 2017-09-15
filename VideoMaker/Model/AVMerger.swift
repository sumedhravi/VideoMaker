//
//  AVMerger.swift
//  VideoMaker
//
//  Created by Sumedh Ravi on 14/09/17.
//  Copyright © 2017 Sumedh Ravi. All rights reserved.
//

import UIKit
import AVFoundation


class AVMerger: NSObject {
    
    var audioFileURL = URL(fileURLWithPath: "")
    var videoFileURL = NSURL(fileURLWithPath: "")
    var outputVideoUrl = NSURL(fileURLWithPath: "")
    let fileName = "CompositeSampleVideo"
    
    //    func addWatermark(){
    //        let parentLayer = CALayer()
    //        let videoLayer = CALayer()
    //        parentLayer.frame = CGRect(x: 0, y: 0, width: 1280, height: 720)
    //        videoLayer.frame = CGRect(x: 0, y: 0, width: 1280, height: 720)
    //        parentLayer.addSublayer(videoLayer)
    //
    //    }
    
    
    func mergeFilesWithUrl(videoUrl: NSURL, audioUrl: NSURL , watermark: Bool, completionHandler : @escaping (NSURL?)->Void) {
        
        let mixComposition: AVMutableComposition = AVMutableComposition()
        var mutableCompositionVideoTrack: [AVMutableCompositionTrack] = []
        var mutableCompositionAudioTrack: [AVMutableCompositionTrack] = []
        let totalVideoCompositionInstruction: AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        
        let aVideoAsset : AVAsset = AVAsset(url: videoUrl as URL)
        let aAudioAsset : AVAsset = AVAsset(url: audioUrl as URL)
        
        mutableCompositionVideoTrack.append(mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid))
        mutableCompositionAudioTrack.append( mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid))
        
        let aVideoAssetTrack : AVAssetTrack = aVideoAsset.tracks(withMediaType: AVMediaTypeVideo)[0]
        let aAudioAssetTrack : AVAssetTrack = aAudioAsset.tracks(withMediaType: AVMediaTypeAudio)[0]
    
        do {
            try mutableCompositionVideoTrack[0].insertTimeRange(CMTimeRangeMake(kCMTimeZero, aVideoAssetTrack.timeRange.duration), of: aVideoAssetTrack, at: kCMTimeZero)
            
            try mutableCompositionAudioTrack[0].insertTimeRange(CMTimeRangeMake(kCMTimeZero, aVideoAssetTrack.timeRange.duration), of: aAudioAssetTrack, at: kCMTimeZero)
            
        } catch {}
        
        totalVideoCompositionInstruction.timeRange = CMTimeRangeMake(kCMTimeZero,aVideoAssetTrack.timeRange.duration)
        
        
        //////
        
        let videolayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: mutableCompositionVideoTrack[0])
        
        let videoAssetTrack = aVideoAsset.tracks(withMediaType: AVMediaTypeVideo)[0]
        videolayerInstruction.setTransform(videoAssetTrack.preferredTransform, at: kCMTimeZero)
        
        totalVideoCompositionInstruction.layerInstructions = [videolayerInstruction]
    
        
     /////////
        
        
        let parentLayer = CALayer()
        let videoLayer = CALayer()
        let imageLayer = CALayer()
        
        let watermarkImage = #imageLiteral(resourceName: "LaunchScreen")
        
        imageLayer.contents = watermarkImage.cgImage
        imageLayer.masksToBounds = true
        imageLayer.frame = CGRect(x: 100, y: 0, width: 150, height: 150)
        imageLayer.opacity = 0.5

        parentLayer.frame = CGRect(x: 0, y: 0, width: aVideoAssetTrack.naturalSize.width, height: aVideoAssetTrack.naturalSize.height)
        videoLayer.frame = CGRect(x: 0, y: 0, width: aVideoAssetTrack.naturalSize.width, height: aVideoAssetTrack.naturalSize.height)
        parentLayer.addSublayer(videoLayer)
        parentLayer.addSublayer(imageLayer)
        
        let mutableVideoComposition : AVMutableVideoComposition = AVMutableVideoComposition()
        mutableVideoComposition.frameDuration = CMTimeMake(1, 30)
        mutableVideoComposition.renderSize = aVideoAssetTrack.naturalSize
        mutableVideoComposition.instructions = [totalVideoCompositionInstruction]
        
        // Set the image layer
        mutableVideoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        
        
        
        //        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: mutableCompositionVideoTrack[0])
        //        let assetTrack = aVideoAsset.tracks(withMediaType: AVMediaTypeVideo)[0]
        //        var scaleToFitRatio = UIScreen.main.bounds.width / assetTrack.naturalSize.width
        //        scaleToFitRatio = UIScreen.main.bounds.width / assetTrack.naturalSize.height
        //        let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
        //        layerInstruction.setTransform(assetTrack.preferredTransform.concatenating(scaleFactor),
        //                                 at: kCMTimeZero)
        //        totalVideoCompositionInstruction.layerInstructions = [layerInstruction]
        //        mutableVideoComposition.instructions = [totalVideoCompositionInstruction]
        
        //        playerItem = AVPlayerItem(asset: mixComposition)
        //        player = AVPlayer(playerItem: playerItem!)
        //
        //
        //        AVPlayerVC.player = player
        
        
        
        //find video on this URl
        
        var savePathUrl = URL(fileURLWithPath: "")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-YYYY hh-mm-ss"
        let fileManager = FileManager.default
        if let tmpDirURL = try? fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
            savePathUrl = tmpDirURL.appendingPathComponent(fileName+""+"\(Date().timeIntervalSince1970)").appendingPathExtension("mp4")
        }
        else{
            fatalError("URLForDirectory() failed")
        }
        
        let assetExport: AVAssetExportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)!
        assetExport.outputFileType = AVFileTypeMPEG4
        assetExport.outputURL = savePathUrl
        assetExport.shouldOptimizeForNetworkUse = true
        assetExport.videoComposition = mutableVideoComposition
        
        assetExport.exportAsynchronously { () -> Void in
            switch assetExport.status {
                
            case AVAssetExportSessionStatus.completed:
                
                self.outputVideoUrl = savePathUrl as NSURL
                completionHandler(savePathUrl as NSURL)
                
                
                print("success")
            case  AVAssetExportSessionStatus.failed:
                print("failed \(assetExport.error)")
                
                if completionHandler != nil {
                    completionHandler(nil)
                }
            case AVAssetExportSessionStatus.cancelled:
                print("cancelled \(assetExport.error)")
                
                if completionHandler != nil {
                    completionHandler(nil)
                }
            default:
                print("complete")
                
                if completionHandler != nil {
                    completionHandler(nil)
                }
            }
        }
    }
    
}
