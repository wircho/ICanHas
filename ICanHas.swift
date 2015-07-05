import Foundation

import UIKit

import CoreLocation

import AVFoundation

import Photos

import AddressBookUI

import EventKit

public class ICanHas {
    
    private class func onMain(closure:()->Void) {
        dispatch_async(dispatch_get_main_queue(), closure)
    }
    
    static var didTryToRegisterForPush = false
    
    static var isHasingPush = false
    static var isHasingLocation = false
    static var isHasingCapture:[String:Bool] = [AVMediaTypeAudio:false,AVMediaTypeClosedCaption:false,AVMediaTypeMetadata:false,AVMediaTypeMuxed:false,AVMediaTypeSubtitle:false,AVMediaTypeText:false,AVMediaTypeTimecode:false,AVMediaTypeVideo:false]
    static var isHasingPhotos = false
    static var isHasingContacts = false
    static var isHasingCalendar:[Int:Bool] = [EKEntityTypeEvent:false,EKEntityTypeReminder:false]
    
    static var hasPushClosures:[(authorized:Bool)->Void] = []
    static var hasLocationClosures:[(authorized:Bool,status:CLAuthorizationStatus)->Void] = []
    static var hasCaptureClosures:[String:[(authorized:Bool,status:AVAuthorizationStatus)->Void]] = [AVMediaTypeAudio:[],AVMediaTypeClosedCaption:[],AVMediaTypeMetadata:[],AVMediaTypeMuxed:[],AVMediaTypeSubtitle:[],AVMediaTypeText:[],AVMediaTypeTimecode:[],AVMediaTypeVideo:[]]
    static var hasPhotosClosures:[(authorized:Bool,status:PHAuthorizationStatus)->Void] = []
    static var hasContactsClosures:[(authorized:Bool,status:ABAuthorizationStatus,error:CFError!)->Void] = []
    static var hasCalendarClosures:[Int:[(authorized:Bool,error:NSError!)->Void]] = [EKEntityTypeEvent:[],EKEntityTypeReminder:[]]
    
    public class func Calendar(store:EKEventStore = EKEventStore(), entityType type:Int = EKEntityTypeEvent, closure:(authorized:Bool,error:NSError!)->Void) {
        
        onMain {
            ICanHas.hasCalendarClosures[type]!.append(closure)
            
            if !ICanHas.isHasingCalendar[type]! {
                
                ICanHas.isHasingCalendar[type] = true
                let done = {
                    (authorized:Bool,error:NSError!)->Void in
                    
                    let array = ICanHas.hasCalendarClosures[type]!
                    ICanHas.hasCalendarClosures[type] = []
                    
                    array.map{$0(authorized:authorized,error:error)}
                    
                    ICanHas.isHasingCalendar[type] = false
                }
                
                store.requestAccessToEntityType(type, completion: { (authorized:Bool, error:NSError!) -> Void in
                    
                   ICanHas.onMain {
                        done(authorized,error)
                    }
                    
                })
            }
        }
        
    }
    
    public class func Contacts(addressBook:ABAddressBookRef? = ABAddressBookCreateWithOptions(nil, nil)?.takeRetainedValue(), closure:(authorized:Bool,status:ABAuthorizationStatus,error:CFError!)->Void) {
        
        onMain {
            
            ICanHas.hasContactsClosures.append(closure)
            
            if !ICanHas.isHasingContacts {
                ICanHas.isHasingContacts = true
                let done = {
                    (authorized:Bool,status:ABAuthorizationStatus,error:CFError!)->Void in
                    
                    let array = ICanHas.hasContactsClosures
                    ICanHas.hasContactsClosures = []
                    
                    array.map{$0(authorized:authorized,status:status,error:error)}
                    
                    ICanHas.isHasingContacts = false
                }
                
                let currentStatus = ABAddressBookGetAuthorizationStatus()
                
                switch currentStatus {
                case .Denied:
                    done(false,currentStatus,nil)
                case .Restricted:
                    done(false,currentStatus,nil)
                case .Authorized:
                    done(true,currentStatus,nil)
                case .NotDetermined:
                    ABAddressBookRequestAccessWithCompletion(addressBook, { (authorized:Bool, error:CFError!) -> Void in
                        
                        ICanHas.onMain {
                            done(authorized,ABAddressBookGetAuthorizationStatus(),error)
                        }
                        
                    })
                }
                
                
            }
            
        }
        
    }
    
    public class func Photos(closure:(authorized:Bool,status:PHAuthorizationStatus)->Void) {
        
        onMain {
            
            ICanHas.hasPhotosClosures.append(closure)
            
            if !ICanHas.isHasingPhotos {
                ICanHas.isHasingPhotos = true
                
                let done = {
                    (authorized:Bool,status:PHAuthorizationStatus) -> Void in
                    
                    let array = ICanHas.hasPhotosClosures
                    ICanHas.hasPhotosClosures = []
                    
                    array.map{$0(authorized:authorized,status:status)}
                    
                    ICanHas.isHasingPhotos = false
                }
                
                let currentStatus = PHPhotoLibrary.authorizationStatus()
                
                switch currentStatus {
                case .Denied:
                    done(false,currentStatus)
                case .Restricted:
                    done(false,currentStatus)
                case .Authorized:
                    done(true,currentStatus)
                case .NotDetermined:
                    PHPhotoLibrary.requestAuthorization({ (status:PHAuthorizationStatus) -> Void in
                        
                        ICanHas.onMain {
                            done(status == PHAuthorizationStatus.Authorized, status)
                        }
                        
                        
                        
                    })
                }
            }
            
            
            
        }
        
    }
    
    public class func Capture(type:String = AVMediaTypeVideo,closure:(authorized:Bool,status:AVAuthorizationStatus)->Void) {
        onMain {
            
            ICanHas.hasCaptureClosures[type]!.append(closure)
            
            if !ICanHas.isHasingCapture[type]! {
                ICanHas.isHasingCapture[type] = true
                
                let done = {
                    (authorized:Bool,status:AVAuthorizationStatus) -> Void in
                    
                    let array = ICanHas.hasCaptureClosures[type]!
                    ICanHas.hasCaptureClosures[type] = []
                    
                    array.map{$0(authorized:authorized,status:status)}
                    
                    ICanHas.isHasingCapture[type] = false
                }
                
                let currentStatus = AVCaptureDevice.authorizationStatusForMediaType(type)
                
                switch currentStatus {
                case .Denied:
                    done(false,currentStatus)
                case .Restricted:
                    done(false,currentStatus)
                case .Authorized:
                    done(true,currentStatus)
                case .NotDetermined:
                    AVCaptureDevice.requestAccessForMediaType(type, completionHandler: { (authorized:Bool) -> Void in
                        
                        ICanHas.onMain {
                            done(authorized,AVCaptureDevice.authorizationStatusForMediaType(type))
                        }
                        
                        
                    })
                }
                
            }
            
        }
    }
    
    
    public class func Push(types:UIUserNotificationType = UIUserNotificationType.Alert |
        UIUserNotificationType.Badge |
        UIUserNotificationType.Sound,closure:(authorized:Bool)->Void) {
            
            onMain {
                
                ICanHas.hasPushClosures.append(closure)
                
                if !ICanHas.isHasingPush {
                    ICanHas.isHasingPush = true
                    
                    let done = {
                        (authorized:Bool) -> Void in
                        
                        let array = ICanHas.hasPushClosures
                        ICanHas.hasPushClosures = []
                        
                        array.map{$0(authorized:authorized)}
                        
                        ICanHas.isHasingPush = false
                    }
                    
                    let application:UIApplication! = UIApplication.sharedApplication()
                    
                    if ICanHas.didTryToRegisterForPush {
                        done(application.isRegisteredForRemoteNotifications())
                    }else {
                        ICanHas.didTryToRegisterForPush = true
                        
                        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: types, categories: nil))
                        
                        var bgNoteObject:NSObjectProtocol! = nil
                        var fgNoteObject:NSObjectProtocol! = nil
                        
                        var hasTimedOut = false
                        
                        var hasGoneToBG = false
                        
                        var shouldWaitForFG = false
                        
                        bgNoteObject = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillResignActiveNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (note:NSNotification!) -> Void in
                            
                            hasGoneToBG = true
                            
                            if !hasTimedOut {
                                shouldWaitForFG = true
                            }
                            
                            bgNoteObject = nil
                        }
                        
                        fgNoteObject = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (note:NSNotification!) -> Void in
                            
                            if shouldWaitForFG {
                                done(application.isRegisteredForRemoteNotifications())
                            }
                            
                            fgNoteObject = nil
                        }
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(1 * Double(NSEC_PER_SEC))),dispatch_get_main_queue(), {
                            
                            hasTimedOut = true
                            
                            if !hasGoneToBG {
                                done(application.isRegisteredForRemoteNotifications())
                            }
                            
                        })
                        
                        
                        application.registerForRemoteNotifications()
                        
                    }
                    
                }
                
                
                
                
                
                
            }
    }
    
    public class func Location(background:Bool = false, manager mngr:CLLocationManager? = nil, closure:(authorized:Bool,status:CLAuthorizationStatus) -> Void) {
        
        onMain {
            ICanHas.hasLocationClosures.append(closure)
            
            if !ICanHas.isHasingLocation {
                ICanHas.isHasingLocation = true
                
                let done = {
                    (authorized:Bool,status:CLAuthorizationStatus) -> Void in
                    
                    let array = ICanHas.hasLocationClosures
                    ICanHas.hasLocationClosures = []
                    
                    array.map{$0(authorized:authorized,status:status)}
                    
                    ICanHas.isHasingLocation = false
                }
                
                let currentStatus = CLLocationManager.authorizationStatus()
                let callback = {(authorized:Bool) -> Void in
                    done(authorized, currentStatus)
                }
                switch currentStatus {
                case .AuthorizedAlways:
                    callback(true)
                case .Denied:
                    callback(false)
                case .Restricted:
                    callback(false)
                case .AuthorizedWhenInUse:
                    if background {
                        fallthrough
                    }else {
                        callback(true)
                    }
                case .NotDetermined:
                    var manager:CLLocationManager! = mngr ?? CLLocationManager()
                    manager.requestWhenInUseAuthorization()
                    
                    var listener:_ICanHasListener! = _ICanHasListener()
                    var removeListener:(()->Void)! = nil
                    
                    if let delegate = manager.delegate {
                        var lastDelegate:NSObject = delegate as! NSObject
                        var retainedObjects:[AnyObject]! = []
                        retainedObjects.append(lastDelegate)
                        while lastDelegate._ich_listener != nil {
                            lastDelegate = lastDelegate._ich_listener
                            retainedObjects.append(lastDelegate)
                        }
                        lastDelegate._ich_listener = listener
                        removeListener = {
                            lastDelegate._ich_listener = nil
                            retainedObjects = nil
                            listener = nil
                            manager = nil
                            removeListener = nil
                        }
                    }else {
                        manager.delegate = listener
                        removeListener = {
                            manager.delegate = nil
                            listener = nil
                            manager = nil
                            removeListener = nil
                        }
                    }
                    
                    
                    listener.changedLocationPermissions = {
                        (status:CLAuthorizationStatus) -> Void in
                        
                        ICanHas.onMain {
                            if status != .NotDetermined && status != currentStatus {
                                
                                removeListener()
                                
                                if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
                                    done(true,status)
                                }else {
                                    done(false,status)
                                }
                            }
                        }
                    }
                    
                    if background {
                        assert(
                            NSBundle.mainBundle().objectForInfoDictionaryKey(
                                "NSLocationAlwaysUsageDescription"
                                ) != nil,
                            "Make sure to add the key 'NSLocationAlwaysUsageDescription' to your info.plist file!"
                        )
                        
                        manager.requestAlwaysAuthorization()
                    }else {
                        
                        assert(
                            NSBundle.mainBundle().objectForInfoDictionaryKey(
                                "NSLocationWhenInUseUsageDescription"
                                ) != nil,
                            "Make sure to add the key 'NSLocationWhenInUseUsageDescription' to your info.plist file!"
                        )
                        manager.requestWhenInUseAuthorization()
                    }
                    
                }
            }
        }
        
        
    }
    
}

private var _ICanHasListenerHandler: UInt8 = 0
private var _ICanHasSwitched = false

extension NSObject {
    
    private var _ich_listener:_ICanHasListener! {
        set {
            if !_ICanHasSwitched {
                
                [
                    ("locationManager:didChangeAuthorizationStatus:","_ICanHas_locationManager:didChangeAuthorizationStatus:"),
                    ("application:didRegisterForRemoteNotificationsWithDeviceToken:","_ICanHas_application:didRegisterForRemoteNotificationsWithDeviceToken:"),
                    ("application:didFailToRegisterForRemoteNotificationsWithError:","_ICanHas_application:didFailToRegisterForRemoteNotificationsWithError:")
                    ]
                    .map {
                        method_exchangeImplementations(
                            class_getInstanceMethod(NSObject.self,Selector(stringLiteral: $0.0)),
                            class_getInstanceMethod(NSObject.self,Selector(stringLiteral: $0.1))
                        )
                }
                
                _ICanHasSwitched = true
            }
            objc_setAssociatedObject(self, &_ICanHasListenerHandler, newValue, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
        }
        get {
            return objc_getAssociatedObject(self, &_ICanHasListenerHandler) as? _ICanHasListener
        }
    }
    
    //Empty implementations:
    public func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    }
    public func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
    }
    public func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
    }
    
    //Added implementations
    public func _ICanHas_locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        self._ich_listener?.locationManager(manager, didChangeAuthorizationStatus: status)
        
        self._ICanHas_locationManager(manager, didChangeAuthorizationStatus: status)
    }
    
    public func _ICanHas_application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        self._ich_listener?.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        
        self._ICanHas_application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    public func _ICanHas_application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        self._ich_listener?.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
        
        self._ICanHas_application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }
    
}

public class _ICanHasListener:NSObject,CLLocationManagerDelegate,UIApplicationDelegate {
    var changedLocationPermissions:((CLAuthorizationStatus)->Void)!
    var registeredForPush:((NSData)->Void)!
    var failedToRegisterForPush:((NSError)->Void)!
    
    public override func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        self.changedLocationPermissions?(status)
    }
    
    public override func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        self.registeredForPush?(deviceToken)
    }
    public override func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        self.failedToRegisterForPush?(error)
    }
}
