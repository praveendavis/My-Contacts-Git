//
//  ContactDetail.swift
//  My Contacts
//
//  Created by Mac User on 18/09/18.
//  Copyright © 2018 Praveen. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ContactDetailController: UIViewController {
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var country: UILabel!
    
    var Uname:String!
    var Uemail:String!
    var Uphone:String!
    var Ucountry:String!
    var Uimage: NSData!
    


    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        name.text = Uname
        email.text = Uemail
        phone.text = Uphone
        country.text = Ucountry
        

        profile.layer.cornerRadius = profile.frame.size.width/2
        profile.layer.masksToBounds = true

        
            if let image = UIImage(data:Uimage as Data) as UIImage! {
                profile.image = image
            }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
