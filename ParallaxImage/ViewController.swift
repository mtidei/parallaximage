//
//  ViewController.swift
//  ParallaxImage
//
//  Created by Maurizio Tidei on 28/12/14.
//  Copyright (c) 2014 contexagon. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var parallaxImageView: ParallaxImageView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //parallaxImageView.setLayerWithZCoordinate(-8,  image: UIImage(named: "artillerie-bg.png")!)
        //parallaxImageView.setLayerWithZCoordinate(3, image: UIImage(named: "artillerie-fg1.png")!)
        //parallaxImageView.setLayerWithZCoordinate(15, image: UIImage(named: "artillerie-fg2.png")!)
        
        parallaxImageView.setLayerWithZCoordinate(-2,  image: UIImage(named: "church-bg.png")!)
        parallaxImageView.setLayerWithZCoordinate(3, image: UIImage(named: "church-fg1.png")!)
        parallaxImageView.setLayerWithZCoordinate(6, image: UIImage(named: "church-fg2.png")!)
        
        parallaxImageView.startGyroParallax()
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

