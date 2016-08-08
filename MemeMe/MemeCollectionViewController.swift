//
//  MemeCollectionViewController.swift
//  MemeMe
//
//  Created by felix on 8/8/16.
//  Copyright © 2016 Felix Chen. All rights reserved.
//

import UIKit

class MemeCollectionViewController: UICollectionViewController {

    @IBAction func add(sender: UIBarButtonItem) {
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let resultVC = storyboard.instantiateViewControllerWithIdentifier("MemeMeViewController")as! MemeMeViewController
        
        presentViewController(resultVC, animated: true, completion:nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        collectionView?.reloadData()
        tabBarController?.tabBar.hidden = false
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getMemeModel().count()
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("memeCollectionCell", forIndexPath: indexPath) as! MemeCollectionViewCell
        
        if let meme = getMemeModel().getItemAt(indexPath.row) {
            cell.topLabel?.text = meme.topText
            cell.bottomLabel?.text = meme.bottomText
            cell.imageView?.image = meme.memedImage
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let resultVC = storyboard.instantiateViewControllerWithIdentifier("MemeDetailViewController")as! MemeDetailViewController
        
        resultVC.meme = getMemeModel().getItemAt(indexPath.row)
        
        tabBarController?.tabBar.hidden = true
        navigationController?.pushViewController(resultVC, animated: true)
    }
    
    func getMemeModel() -> MemeModel{
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.memeModel
    }
}
