//
//  ViewController.swift
//  ICanHasSample
//
//  Created by Adolfo Rodriguez on 2015-07-03.
//  Copyright (c) 2015 Relevant. All rights reserved.
//

import UIKit

private extension Bool {
    var text: String { return self ? "YES" : "NO" }
}

class ViewController: UIViewController {
    @IBOutlet weak var pushLabel: UILabel!
    @IBAction func tappedPush(_ sender: AnyObject) {
        ICanHas.push { authorized in
            self.pushLabel.text = authorized.text
        }
    }
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBAction func tappedLocation(_ sender: AnyObject) {
        ICanHas.location { authorized, status in
            self.locationLabel.text = authorized.text
        }
    }
    
    @IBOutlet weak var cameraLabel: UILabel!
    @IBAction func tappedCamera(_ sender: AnyObject) {
        ICanHas.capture { authorized, status in
            self.cameraLabel.text = authorized.text
        }
    }
    
    @IBOutlet weak var photosLabel: UILabel!
    @IBAction func tappedPhotos(_ sender: AnyObject) {
        ICanHas.photos { authorized, status in
            self.photosLabel.text = authorized.text
        }
    }
    
    @IBOutlet weak var contactsLabel: UILabel!
    @IBAction func tappedContacs(_ sender: AnyObject) {
        ICanHas.contacts { authorized, status, error in
            self.contactsLabel.text = authorized.text
        }
    }
    
    @IBOutlet weak var calendarLabel: UILabel!
    @IBAction func tappedCalendar(_ sender: AnyObject) {
        ICanHas.calendar { authorized, status, error in
            self.calendarLabel.text = authorized.text
            
        }
    }
}

