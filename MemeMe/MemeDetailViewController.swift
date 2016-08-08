//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by felix on 8/6/16.
//  Copyright © 2016 Felix Chen. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var meme: Meme!
    
    @IBAction func editMeme(sender: UIBarButtonItem) {
        
        if let meme = meme {
            
            let storyboard = UIStoryboard (name: "Main", bundle: nil)
            let resultVC = storyboard.instantiateViewControllerWithIdentifier("MemeMeViewController")as! MemeMeViewController
            
            resultVC.topText = meme.topText
            resultVC.bottomText = meme.bottomText
            resultVC.image = meme.originalImage
            
            presentViewController(resultVC, animated: true, completion:nil)
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let meme = meme {
            imageView.image = meme.memedImage
        }
        
    }
}
