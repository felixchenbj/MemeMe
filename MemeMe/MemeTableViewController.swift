//
//  MemeTableViewController.swift
//  MemeMe
//
//  Created by felix on 8/6/16.
//  Copyright © 2016 Felix Chen. All rights reserved.
//

import UIKit

class MemeTableViewController: UITableViewController  {
    
    @IBAction func edit(sender: UIBarButtonItem) {
        tableView.setEditing(!tableView.editing, animated: true)
    }
    
    @IBAction func add(sender: UIBarButtonItem) {
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let resultVC = storyboard.instantiateViewControllerWithIdentifier("MemeMeViewController")as! MemeMeViewController
        
        presentViewController(resultVC, animated: true, completion:nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Table view load meme list, list count is \(getMemeModel().count())")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        tabBarController?.tabBar.hidden = false
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getMemeModel().count()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("memeTableCell", forIndexPath: indexPath) as! MemeTableViewCell
        
        if let meme = getMemeModel().getItemAt(indexPath.row) {
            cell.thumbnailView?.image = meme.memedImage
            cell.topLabel?.text = meme.topText
            cell.bottomLabel?.text = meme.bottomText
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("table row selected")
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let resultVC = storyboard.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
        
        resultVC.meme = getMemeModel().getItemAt(indexPath.row)
        
        tabBarController?.tabBar.hidden = true
        navigationController?.pushViewController(resultVC, animated: true)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:
            print("Delete a table view cell")
            // delete meme in the model
            getMemeModel().remove(indexPath.row)
            // delete meme in the table view
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        default:
            print("Do nothing")
        }
    }
    
    func getMemeModel() -> MemeModel{
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.memeModel
    }
}
