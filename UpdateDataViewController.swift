//
//  UpdateDataViewController.swift
//  ExerciseCoreData
//
//  Created by Yolanda Halim on 27/02/19.
//  Copyright © 2019 Yolanda Halim. All rights reserved.
//

import UIKit
import CoreData

class UpdateDataViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var imagePreview: UIImageView!
    
    let imagePicker = UIImagePickerController()
    var loadedPerson: NSManagedObject = NSManagedObject()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        
        let image = UIImage(data: (loadedPerson.value(forKey: "photo") as! Data?)!)
        image?.draw(in: imagePreview.bounds)
        imagePreview.image = image
        nameTF.text = loadedPerson.value(forKey: "name") as? String
    }

    @IBAction func changeImage(_ sender: UITapGestureRecognizer) {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action: UIAlertAction) in
            self.getImage(fromSourceType: .camera)
        }))
        alert.addAction(UIAlertAction(title: "Photo Album", style: .default, handler: {(action: UIAlertAction) in
            self.getImage(fromSourceType: .photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: update data
    @IBAction func updateData(_ sender: Any) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let managedContact = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")
            fetchRequest.predicate = NSPredicate(format: "name = %@", loadedPerson.value(forKey: "name") as! String)

            do {
                let willUpdatedContact = try managedContact.fetch(fetchRequest)
                let contactUpdate = willUpdatedContact[0] as! NSManagedObject
                contactUpdate.setValue(nameTF.text, forKey: "name")

                // MARK: update image
                if let imgData: NSData = imagePreview.image?.pngData() as NSData? {
                    // write the image data to file
                    let savePath: String = self.documentsPath()! + "/" + self.presentDateTimeString() + ".png"
                    imgData.write(toFile: savePath, atomically: true)
                    contactUpdate.setValue(imgData, forKey: "photo")
                }

                do {
                    try managedContact.save()
                    print("Update finished")
                    self.navigationController?.popToRootViewController(animated: true)
                } catch {
                    print(error)
                }
            } // do
            catch {
                print(error)
            }
        }
    }
    
    // MARK: get image from the source
    func getImage(fromSourceType sourceType: UIImagePickerController.SourceType) {
        
        //Check is source type available
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = sourceType
            imagePickerController.allowsEditing = true
            self.present(imagePickerController, animated: true, completion: nil)
        } else {
            if sourceType == UIImagePickerController.SourceType.camera {
                let alert: UIAlertController = UIAlertController(title: "Camera Unavailable", message: "Unable to find a camera on this device", preferredStyle: UIAlertController.Style.alert)
                self.present(alert, animated: true, completion: nil)
                if self.becomeFirstResponder() {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    // MARK: set image to the image view
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // try to get our edited image if there is one, as well as the original image
        let editedImg: UIImage?   = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        let originalImg: UIImage? = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        imagePreview.image = editedImg == nil ? originalImg : editedImg
        
        // dismiss the picker
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: set the location of the image
    func documentsPath() ->String?
    {
        // fetch our paths
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        
        if paths.count > 0
        {
            // return our docs directory path if we have one
            let docsDir = paths[0]
            return docsDir
        }
        return nil
    }
    
    func presentDateTimeString() ->String
    {
        // setup date formatter
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        
        // get current date
        let now: Date = Date()
        
        // generate date string from now
        let theDateTime = dateFormatter.string(from: now as Date)
        return theDateTime
    }


}
