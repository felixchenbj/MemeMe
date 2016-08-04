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
    
    var meme: Meme!
    
    let memeTextAttributes = [ NSStrokeColorAttributeName : UIColor.darkGrayColor(),
                               NSForegroundColorAttributeName : UIColor.whiteColor(),
                               NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
                               NSStrokeWidthAttributeName : -5.0
                             ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        
        topTextField.textAlignment = .Center
        bottomTextField.textAlignment = .Center
        
        originalViewY = self.view.frame.origin.y
        
        topTextField.delegate = self
        bottomTextField.delegate = self
        
        if imageView.image == nil {
            actionButton.enabled = false
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.unsubscribeFromKeyboardNotifications()
    }
    
    @IBAction func selectAlbum(sender: UIBarButtonItem) {
        let pickerController = UIImagePickerController()
        pickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        pickerController.delegate = self
        self.presentViewController(pickerController, animated: true, completion:nil)
    }

    @IBAction func selectCamera(sender: UIBarButtonItem) {
        let pickerController = UIImagePickerController()
        pickerController.sourceType = UIImagePickerControllerSourceType.Camera
        pickerController.delegate = self
        self.presentViewController(pickerController, animated: true, completion:nil)
    }
    
    @IBAction func share(sender: UIBarButtonItem) {
        let image = generateMemedImage()
        let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        controller.completionWithItemsHandler = { (activityType:String?, completed:Bool, returnedItems:[AnyObject]?, activityError:NSError?) -> Void in
            if completed {
                // save to the meme
                self.save()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        self.presentViewController(controller, animated: true, completion: nil)
    }
 
    @IBAction func cancel(sender: UIBarButtonItem) {
        topTextField.text = ""
        bottomTextField.text = ""
        imageView.image = nil
        
        actionButton.enabled = false
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
            self.dismissViewControllerAnimated(true, completion: nil)
            print("dismiss")
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
            var userInfo = notification.userInfo!
            let animationDurarion = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
            UIView.animateWithDuration(animationDurarion, animations: { () -> Void in
                self.view.frame.origin.y -= self.getKeyboardHeight(notification)
            } )
        }
    }
 
    func keyboardWillHide(notification:NSNotification) {
        var userInfo = notification.userInfo!
        let animationDurarion = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
        UIView.animateWithDuration(animationDurarion, animations: { () -> Void in
            self.view.frame.origin.y = self.originalViewY
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
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func save() {
        meme = Meme( topText: topTextField.text!,
                     bottomText: bottomTextField.text!,
                     originalImage: imageView.image,
                     memedImage: generateMemedImage()
                   )
    }
    
    func generateMemedImage() -> UIImage {
        
        topToolbar.hidden = true
        bottomToolBar.hidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawViewHierarchyInRect(self.view.frame,
                                     afterScreenUpdates: true)
        let memedImage : UIImage =
            UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
        topToolbar.hidden = false
        bottomToolBar.hidden = false
        
        return memedImage
    }
}

