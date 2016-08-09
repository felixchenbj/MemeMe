//
//  MemeCollectionViewController.swift
//  MemeMe
//
//  Created by felix on 8/8/16.
//  Copyright © 2016 Felix Chen. All rights reserved.
//

import UIKit

class MemeCollectionViewController: UICollectionViewController {

    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    var memeModel: MemeModel {
        get {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            return appDelegate.memeModel
        }
    }
    
    @IBAction func add(sender: UIBarButtonItem) {
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let resultVC = storyboard.instantiateViewControllerWithIdentifier("MemeMeViewController")as! MemeMeViewController
        
        presentViewController(resultVC, animated: true, completion:nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let space: CGFloat = 3.0
        
        collectionViewFlowLayout.minimumInteritemSpacing = space
        collectionViewFlowLayout.minimumLineSpacing = space
        collectionViewFlowLayout.itemSize = CGSizeMake(100, 145)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        collectionView?.reloadData()
        tabBarController?.tabBar.hidden = false
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memeModel.count()
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("memeCollectionCell", forIndexPath: indexPath) as! MemeCollectionViewCell
        
        if let meme = memeModel.getItemAt(indexPath.row) {
            cell.topLabel?.text = meme.topText
            cell.bottomLabel?.text = meme.bottomText
            cell.imageView?.image = meme.memedImage
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let resultVC = storyboard.instantiateViewControllerWithIdentifier("MemeDetailViewController")as! MemeDetailViewController
        
        resultVC.meme = memeModel.getItemAt(indexPath.row)
        
        tabBarController?.tabBar.hidden = true
        navigationController?.pushViewController(resultVC, animated: true)
    }
    
}
