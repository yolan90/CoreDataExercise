//
//  AddPersonViewController.swift
//  ExerciseCoreData
//
//  Created by Yolanda Halim on 20/02/19.
//  Copyright © 2019 Yolanda Halim. All rights reserved.
//

import UIKit
import CoreData

class AddPersonViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var photoPreview: UIImageView!

    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
    }
    
    @IBAction func addPerson(_ sender: Any) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let context = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Person", in: context)
            let person = NSManagedObject(entity: entity!, insertInto: context)
            person.setValue(nameTF.text, forKey: "name")
            
            // create our image data with the edited img if we have one, else use the original image
            if let imgData: NSData = photoPreview.image?.pngData() as NSData? {
            
                // write the image data to file
                let savePath: String = self.documentsPath()! + "/" + self.presentDateTimeString() + ".png"
                imgData.write(toFile: savePath, atomically: true)
                person.setValue(imgData, forKey: "photo")
            }
            
            do {
                try context.save()
            } catch let error as NSError {
                print("Could not save new person. \(error), \(error.userInfo)")
            }
        }
    }
    
    @IBAction func chooseImage(_ sender: Any) {
        showAlert()
    }

    func showAlert() {
        
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
    
    //get image from source type
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // try to get our edited image if there is one, as well as the original image
        let editedImg: UIImage?   = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        let originalImg: UIImage? = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        photoPreview.image = editedImg == nil ? originalImg : editedImg

        // dismiss the picker
        self.dismiss(animated: true, completion: nil)
    }
    
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

