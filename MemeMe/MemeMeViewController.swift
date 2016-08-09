//
//  MemeMeViewController.swift
//  MemeMe
//
//  Created by felix on 8/3/16.
//  Copyright © 2016 Felix Chen. All rights reserved.
//

import UIKit

class MemeMeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    var originalViewY: CGFloat = 0.0
    
    var topText:String!
    var bottomText:String!
    var image: UIImage!
    
    var memeModel: MemeModel {
        get {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            return appDelegate.memeModel
        }
    }
    
    let memeTextAttributes = [ NSStrokeColorAttributeName : UIColor.blackColor(),
                               NSForegroundColorAttributeName : UIColor.whiteColor(),
                               NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
                               NSStrokeWidthAttributeName : -5.0
                             ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTextFields(topTextField)
        configureTextFields(bottomTextField)
        
        originalViewY = self.view.frame.origin.y
        
        topTextField.delegate = self
        bottomTextField.delegate = self
        
        if let topText = topText {
            topTextField.text = topText
        }
        if let bottomText = bottomText {
            bottomTextField.text = bottomText
        }
        if let image = image {
            imageView.image = image
        }
        
        if imageView.image == nil {
            actionButton.enabled = false
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        subscribeToKeyboardNotifications()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromKeyboardNotifications()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func selectAlbum(sender: UIBarButtonItem) {
        selectImageFromSource(UIImagePickerControllerSourceType.PhotoLibrary)
    }

    @IBAction func selectCamera(sender: UIBarButtonItem) {
        selectImageFromSource(UIImagePickerControllerSourceType.Camera)
    }
    
    @IBAction func share(sender: UIBarButtonItem) {
        let image = generateMemedImage()
        let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        controller.completionWithItemsHandler = { (activityType:String?, completed:Bool, returnedItems:[AnyObject]?, activityError:NSError?) -> Void in
            if completed {
                // save to the meme
                self.save()
                
                // switch to the tab view
                self.switchToSavedMeme()
            }
        }
        presentViewController(controller, animated: true, completion: nil)
    }
 
    @IBAction func cancel(sender: UIBarButtonItem) {
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        imageView.image = nil
        
        actionButton.enabled = false
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func selectImageFromSource(sourceType: UIImagePickerControllerSourceType) {
        let pickerController = UIImagePickerController()
        pickerController.sourceType = sourceType
        pickerController.delegate = self
        presentViewController(pickerController, animated: true, completion:nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
            dismissViewControllerAnimated(true, completion: nil)
            actionButton.enabled = true
        }
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MemeMeViewController.keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MemeMeViewController.keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        if isEditingTextFieldWouldBeCoveredByKeyboard(notification) {
            adjustViewToFitKeyboard(notification, offset: getKeyboardHeight(notification) * (-1))
        }
    }
 
    func keyboardWillHide(notification:NSNotification) {
        adjustViewToFitKeyboard(notification, offset: originalViewY)
    }
    
    func adjustViewToFitKeyboard(notification:NSNotification, offset: CGFloat) {
        var userInfo = notification.userInfo!
        let animationDurarion = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
        UIView.animateWithDuration(animationDurarion, animations: { () -> Void in
            self.view.frame.origin.y = offset
        } )
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    func isEditingTextFieldWouldBeCoveredByKeyboard(notification: NSNotification) -> Bool{
        var result = false
        if let userInfo = notification.userInfo,
            keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            
            // if the editing textfield would be covered
            for textfield in [ topTextField, bottomTextField] {
                if textfield.editing && keyboardSize.CGRectValue().intersects(textfield.frame) {
                    result = true
                }
            }
        }
        return result
    }
  
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func configureTextFields(textField: UITextField) {
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .Center
    }
    
    
    func save() {
        // create a Meme
        let meme = Meme( topText: topTextField.text!,
                     bottomText: bottomTextField.text!,
                     originalImage: imageView.image,
                     memedImage: generateMemedImage()
                   )
        // append it to the list
        memeModel.append(meme)
        
        print("Add a new Meme to list, list count is \(memeModel.count())")
    }
    
    func switchToSavedMeme() {
        performSegueWithIdentifier("showTabView", sender: self)
    }
    
    func generateMemedImage() -> UIImage {
        
        // quit editing before generate meme image
        view.endEditing(true)
        
        hiddenToolbars(true)
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawViewHierarchyInRect(self.view.frame,
                                     afterScreenUpdates: true)
        let memedImage : UIImage =
            UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        hiddenToolbars(false)
        
        return memedImage
    }
    
    func hiddenToolbars(hidden: Bool) {
        topToolbar.hidden = hidden
        bottomToolBar.hidden = hidden
    }
    
    func getMemeModel() -> MemeModel{
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.memeModel
    }
}

