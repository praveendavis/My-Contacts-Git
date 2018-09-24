//
//  addcontact.swift
//  My Contacts
//
//  Created by Mac User on 17/09/18.
//  Copyright © 2018 Praveen. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MobileCoreServices
import QuartzCore
import Alamofire
import SwiftValidator



class AddContactViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource,ValidationDelegate, UITextFieldDelegate {
    
        let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var name: UITextField!
    
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var addcontacts: UIButton!
    
    @IBOutlet weak var country: UITextField!
    
    @IBOutlet weak var profilepic: UIImageView!
    


    @IBOutlet weak var fullNameErrorLabel: UILabel!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var phoneNumberErrorLabel: UILabel!
    @IBOutlet weak var countrycodeErrorLabel: UILabel!
    @IBOutlet weak var profilePicErrorLabel: UILabel!

    
    
    var countryData: [String] = [String]()

    var countryPicker: UIPickerView!
    
    var countryPickerValues:[String] = []
    
    var cntryArray:[String] = []
    
    let validator = Validator()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.



        
        validator.styleTransformers(success:{ (validationRule) -> Void in
            print("here")
            // clear error label
            validationRule.errorLabel?.isHidden = true
            validationRule.errorLabel?.text = ""
            if let textField = validationRule.field as? UITextField {
                textField.layer.borderColor = UIColor.green.cgColor
                textField.layer.borderWidth = 0.5
                
            }
        }, error:{ (validationError) -> Void in
            print("error")
            validationError.errorLabel?.isHidden = false
            validationError.errorLabel?.text = validationError.errorMessage
            if let textField = validationError.field as? UITextField {
                textField.layer.borderColor = UIColor.red.cgColor
                textField.layer.borderWidth = 1.0
            }
        })
        

        profilePicErrorLabel.isHidden=true
        validator.registerField(name, errorLabel: fullNameErrorLabel , rules: [RequiredRule()])
        validator.registerField(email, errorLabel: emailErrorLabel, rules: [RequiredRule(), EmailRule()])
        validator.registerField(phone, errorLabel: phoneNumberErrorLabel, rules: [RequiredRule(), MinLengthRule(length: 9)])
        validator.registerField(country, errorLabel: countrycodeErrorLabel, rules: [RequiredRule()])
        



        Alamofire.request("https://restcountries.eu/rest/v1/all").responseJSON { response in
            guard let jsonArray = response.result.value as? [[String: Any]] else {
                return
            }
            for dic in jsonArray{
                guard let title = dic["name"] as? String else { return }
               // print(title) //Output
                self.countryPickerValues.append(title)
            }
        }
        
        
        countryPicker = UIPickerView()
        countryPicker.dataSource = self
        countryPicker.delegate = self
        country.inputView = countryPicker
        
        
        
    }
    
    

    

    
    
    //MARK: - Pickerview method
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countryPickerValues.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countryPickerValues[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        country.text = countryPickerValues[row]
        self.view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        profilepic.layer.cornerRadius = profilepic.frame.size.width/2
        profilepic.layer.masksToBounds = true
        
        let myColor = UIColor.blue
        email.layer.borderColor = myColor.cgColor
        name.layer.borderColor = myColor.cgColor
        phone.layer.borderColor = myColor.cgColor
        country.layer.borderColor = myColor.cgColor
        
        email.layer.borderWidth = 1.0
        name.layer.borderWidth = 1.0
        
        phone.layer.borderWidth = 1.0
        country.layer.borderWidth = 1.0

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
    func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    func storeContact(_ contactName: String,_ contactEmail: String,_ contactPhone: String,_ contactCountry: String) {
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "ContactList", in: context)
        let contact = NSManagedObject(entity: entity!, insertInto: context)
        
        contact.setValue(contactName, forKey: "name")
        contact.setValue(contactEmail, forKey: "email")
        contact.setValue(contactPhone, forKey: "phone")
        contact.setValue(contactCountry, forKey: "country")
        
        let imgData = UIImageJPEGRepresentation(profilepic.image!, 1)
        contact.setValue(imgData, forKey: "imagedata")

        
        
        do {
            try context.save()
           // contacts.append(contact)
        } catch let error as NSError {
            let errorDialog = UIAlertController(title: "Error!", message: "Failed to save! \(error): \(error.userInfo)", preferredStyle: .alert)
            errorDialog.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(errorDialog, animated: true)
        }
    }
    
    @IBAction func upload(_ sender: Any) {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("can't open photo library")
            return
        }
        
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        
        present(imagePicker, animated: true)
        
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        

        self.dismiss(animated: true, completion: {})
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
       // self.storeContact(name.text!,email.text!,phone.text!,country.text!)
      //  self.dismiss(animated: true, completion: {})

        // Check with Valid Email Address
        
        if(profilepic.image == nil)
        {
            profilePicErrorLabel.isHidden=false
        }

        validator.validate(self)
        

    }

    
    // ValidationDelegate methods
    
    func validationSuccessful() {
        
        if(profilepic.image == nil)
        {
            profilePicErrorLabel.isHidden=false
        }
        else
        {
            profilePicErrorLabel.isHidden=true
            self.storeContact(name.text!,email.text!,phone.text!,country.text!)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dataDownloadCompleted"), object: nil)

            self.dismiss(animated: true, completion: {})

        }
        
        
    }
    
    func validationFailed(_ errors:[(Validatable ,ValidationError)]) {
        // turn the fields to red
        
        
        print("Validation FAILED!")
        
        
    }

    
    @objc func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    // MARK: Validate single field
    // Don't forget to use UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        validator.validateField(textField){ error in
            if error == nil {
                // Field validation was successful
            } else {
                // Validation error occurred
            }
        }
        return true
    }
    

    
}



extension AddContactViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        defer {
            picker.dismiss(animated: true)
        }
        
        print(info)
        // get the image
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        
        // do something with it
        profilepic.image = image
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        defer {
            picker.dismiss(animated: true)
        }
        
        print("did cancel")
    }
}

