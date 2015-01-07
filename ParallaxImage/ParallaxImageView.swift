//
//  ParallaxImageView.swift
//  ParallaxImage
//
//  Created by Maurizio Tidei on 28/12/14.
//  Copyright (c) 2014 contexagon. All rights reserved.
//

import UIKit
import CoreMotion

class ParallaxImageView: UIView {
    
    var layers = [ImageLayer]()
    
    var maxWidth = 0
    var maxHeight = 0
    
    let motionManager = CMMotionManager()
    
    var neutralOrientation:CMAcceleration! = nil
    var rotation:CMAcceleration! = CMAcceleration(x: 0, y: 0, z: 0)
    var oldRotation:CMAcceleration! = CMAcceleration(x: 0, y: 0, z: 0)
    
    var neutralAttitude:CMAttitude! = nil
    var relativeAttitude:Attitude = Attitude(pitch: 0, yaw: 0, roll: 0)
    
    
    let epsilon = 0.01
    
    
    func setLayerWithZCoordinate(z: Int, image: UIImage) {
        
        let width  = Int(image.size.width)
        let height = Int(image.size.height)
        
        if width > maxWidth {
            maxWidth = width
        }
        if height > maxHeight {
            maxHeight = height
        }
        
        layers.append(ImageLayer(z:z, image: image.CGImage, x: 0, y: 0, width: width, height: height))
    }
    
    override func drawRect(rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
        CGContextTranslateCTM(context, 0, rect.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        CGContextSetInterpolationQuality(context, kCGInterpolationNone)
        
        var zoomFactor:Double = 1.0
        
        let widthFactor = Double(rect.width) / Double(maxWidth)
        let heightFactor = Double(rect.height) / Double(maxHeight)
        
        if widthFactor < heightFactor {
            zoomFactor = widthFactor
        }
        else {
            zoomFactor = heightFactor
        }
        
        for imageLayer in layers {
            
            var z = imageLayer.z
            
            let imageWidth = Double(imageLayer.width) * zoomFactor
            let imageHeight = Double(imageLayer.height) * zoomFactor
            
            var x = 0.0
            var y = 0.0
            
            if rotation != nil {
                x = (Double(z) - 1) * rotation.x * -1
                y = (Double(z) - 1) * rotation.y * -1
                
    
            }
            
            let imageRect = CGRect(x: x, y: y, width: imageWidth, height: imageHeight)
            CGContextDrawImage(context, imageRect, imageLayer.image)
        }
    }
    
    func startAccelerationParallax() {
        
        let queue = NSOperationQueue()
        
        motionManager.startDeviceMotionUpdatesToQueue(queue, withHandler: {
            
            (data:CMDeviceMotion!, error:NSError!) in
            
            if error != nil {
               NSLog(error.description) 
            }
            
            if (self.neutralOrientation == nil) {
                self.neutralOrientation = data.gravity
            }
            else {
                let gravity = data.gravity
                self.rotation.x = self.neutralOrientation.x - gravity.x
                self.rotation.y = self.neutralOrientation.y - gravity.y
                
                dispatch_async( dispatch_get_main_queue(), {
                    self.setNeedsDisplay()
                })
            }
        })
    }
    
    func startGyroParallax() {
        
        let queue = NSOperationQueue()
        
        //motionManager.deviceMotionUpdateInterval = 0.03
        
        
        motionManager.startDeviceMotionUpdatesUsingReferenceFrame(CMAttitudeReferenceFrameXArbitraryZVertical, toQueue: queue, withHandler: {
            
            (data:CMDeviceMotion!, error:NSError!) in
            
            data.attitude.roll
            
            if error != nil {
                NSLog(error.description)
            }
            
            if (self.neutralOrientation == nil) {
                self.neutralOrientation = CMAcceleration(x: 0, y: 0, z: 0)
                self.neutralOrientation.x = data.attitude.roll
                self.neutralOrientation.y = data.attitude.pitch
            }
            else {
                let attitude = data.attitude
                
                self.rotation.y = self.neutralOrientation.y - attitude.pitch
                self.rotation.x = self.neutralOrientation.x - attitude.roll
                
                if (fabs(self.oldRotation.y - self.rotation.y) > self.epsilon || fabs(self.oldRotation.x - self.rotation.x) > self.epsilon) {
                    
                    self.oldRotation.y = self.rotation.y
                    self.oldRotation.x = self.rotation.x
                    
                    dispatch_async( dispatch_get_main_queue(), {
                        self.setNeedsDisplay()
                        NSLog("set needs display")
                    })
                }
            }
        })
    }
}


struct ImageLayer {
    
    var z:Int
    var image:CGImage
    var x:Int
    var y:Int
    var width:Int
    var height:Int
}

struct Attitude {
    
    var pitch:Double
    var yaw:Double
    var roll:Double
}