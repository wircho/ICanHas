//
//  ViewController.swift
//  ICanHasSample
//
//  Created by Adolfo Rodriguez on 2015-07-03.
//  Copyright (c) 2015 Relevant. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var pushLabel: UILabel!
    @IBAction func tappedPush(sender: AnyObject) {
        ICanHas.Push { (authorized) -> Void in
            
            self.pushLabel.text = authorized ? "YES" : "NO"
            
        }
    }
    @IBOutlet weak var locationLabel: UILabel!
    @IBAction func tappedLocation(sender: AnyObject) {
        
        ICanHas.Location { (authorized, status) -> Void in
            
            self.locationLabel.text = authorized ? "YES" : "NO"
            
        }
    }
    @IBOutlet weak var cameraLabel: UILabel!
    @IBAction func tappedCamera(sender: AnyObject) {
        
        ICanHas.Capture { (authorized, status) -> Void in
            
            self.cameraLabel.text = authorized ? "YES" : "NO"
            
        }
    }
    @IBOutlet weak var photosLabel: UILabel!
    @IBAction func tappedPhotos(sender: AnyObject) {
        
        ICanHas.Photos { (authorized, status) -> Void in
            
            self.photosLabel.text = authorized ? "YES" : "NO"
            
        }
    }
    @IBOutlet weak var contactsLabel: UILabel!
    @IBAction func tappedContacs(sender: AnyObject) {
        
        ICanHas.Contacts { (authorized, status,error) -> Void in
            
            self.contactsLabel.text = authorized ? "YES" : "NO"
            
        }
    }
    @IBOutlet weak var calendarLabel: UILabel!
    @IBAction func tappedCalendar(sender: AnyObject) {
        
        ICanHas.Calendar { (authorized,error) -> Void in
            
            self.calendarLabel.text = authorized ? "YES" : "NO"
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

