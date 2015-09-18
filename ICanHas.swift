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
    static var isHasingCalendar:[EKEntityType:Bool] = [EKEntityType.Event:false,EKEntityType.Reminder:false]
    
    static var hasPushClosures:[(authorized:Bool)->Void] = []
    static var hasLocationClosures:[(authorized:Bool,status:CLAuthorizationStatus)->Void] = []
    static var hasCaptureClosures:[String:[(authorized:Bool,status:AVAuthorizationStatus)->Void]] = [AVMediaTypeAudio:[],AVMediaTypeClosedCaption:[],AVMediaTypeMetadata:[],AVMediaTypeMuxed:[],AVMediaTypeSubtitle:[],AVMediaTypeText:[],AVMediaTypeTimecode:[],AVMediaTypeVideo:[]]
    static var hasPhotosClosures:[(authorized:Bool,status:PHAuthorizationStatus)->Void] = []
    static var hasContactsClosures:[(authorized:Bool,status:ABAuthorizationStatus,error:CFError!)->Void] = []
    static var hasCalendarClosures:[EKEntityType:[(authorized:Bool,error:NSError!)->Void]] = [EKEntityType.Event:[],EKEntityType.Reminder:[]]
    
    public class func CalendarAuthorizationStatus(entityType type:EKEntityType = EKEntityType.Event)->EKAuthorizationStatus {
        return EKEventStore.authorizationStatusForEntityType(type)
    }
    
    public class func CalendarAuthorization(entityType type:EKEntityType = EKEntityType.Event)->Bool {
        return EKEventStore.authorizationStatusForEntityType(type) == .Authorized
    }
    
    public class func Calendar(store:EKEventStore = EKEventStore(), entityType type:EKEntityType = EKEntityType.Event, closure:(authorized:Bool,error:NSError!)->Void) {
        
        onMain {
            ICanHas.hasCalendarClosures[type]!.append(closure)
            
            if !ICanHas.isHasingCalendar[type]! {
                
                ICanHas.isHasingCalendar[type] = true
                let done = {
                    (authorized:Bool,error:NSError!)->Void in
                    
                    let array = ICanHas.hasCalendarClosures[type]!
                    ICanHas.hasCalendarClosures[type] = []
                    
                    let _ = array.map{$0(authorized:authorized,error:error)}
                    
                    ICanHas.isHasingCalendar[type] = false
                }
                
                store.requestAccessToEntityType(type, completion: { (authorized:Bool, error:NSError?) -> Void in
                    
                   ICanHas.onMain {
                        done(authorized,error)
                    }
                    
                })
            }
        }
        
    }
    
    public class func ContactsAuthorizationStatus()->ABAuthorizationStatus {
        return ABAddressBookGetAuthorizationStatus()
    }
    
    public class func ContactsAuthorization()->Bool {
        return ABAddressBookGetAuthorizationStatus() == .Authorized
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
                    
                    let _ = array.map{$0(authorized:authorized,status:status,error:error)}
                    
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
    
    public class func PhotosAuthorizationStatus()->PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus()
    }
    
    public class func PhotosAuthorization()->Bool {
        return PHPhotoLibrary.authorizationStatus() == .Authorized
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
                    
                    let _ = array.map{$0(authorized:authorized,status:status)}
                    
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
    
    public class func CaptureAuthorizationStatus(type:String = AVMediaTypeVideo)->AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatusForMediaType(type)
    }
    
    public class func CaptureAuthorization(type:String = AVMediaTypeVideo)->Bool {
        return AVCaptureDevice.authorizationStatusForMediaType(type) == .Authorized
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
                    
                    let _ = array.map{$0(authorized:authorized,status:status)}
                    
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
    
    public class func PushAuthorization()->Bool {
        return UIApplication.sharedApplication().isRegisteredForRemoteNotifications()
    }
    
//    private static var pushExchangeDone = false
    
    public class func Push(types:UIUserNotificationType = UIUserNotificationType.Alert.union(UIUserNotificationType.Badge).union(UIUserNotificationType.Sound),closure:(authorized:Bool)->Void) {
            
            onMain {
                
//                if !self.pushExchangeDone {
//                    self.pushExchangeDone = true
//                    
//                    let appDelegate:NSObject = UIApplication.sharedApplication().delegate! as! NSObject
//                    
//                    let appDelegateClass:AnyClass = appDelegate.dynamicType
//                    
//                    [
//                        ("application:didRegisterForRemoteNotificationsWithDeviceToken:","_ICanHas_application:didRegisterForRemoteNotificationsWithDeviceToken:"),
//                        ("application:didFailToRegisterForRemoteNotificationsWithError:","_ICanHas_application:didFailToRegisterForRemoteNotificationsWithError:")
//                        ]
//                        .map {
//                            
//                            (pair:(String,String))->Void in
//                            
//                            if String.fromCString(method_getTypeEncoding(class_getInstanceMethod(appDelegateClass, Selector(stringLiteral: pair.0)))) == nil {
//                                
//                                let method = class_getInstanceMethod(NSObject.self, Selector(stringLiteral:"_ICanHas_empty_" + pair.0))
//                                
//                                class_addMethod(appDelegateClass, Selector(stringLiteral:pair.0), method_getImplementation(method), method_getTypeEncoding(method))
//                                
//                            }
//                            
//                            
//                            method_exchangeImplementations(
//                                class_getInstanceMethod(appDelegateClass,Selector(stringLiteral: pair.0)),
//                                class_getInstanceMethod(appDelegateClass,Selector(stringLiteral: pair.1))
//                            )
//                    }
//                    
//                    appDelegate._ich_listener = _ICanHasListener()
//                }
                
                ICanHas.hasPushClosures.append(closure)
                
                if !ICanHas.isHasingPush {
                    ICanHas.isHasingPush = true
                    
                    let done = {
                        (authorized:Bool) -> Void in
                        
                        let array = ICanHas.hasPushClosures
                        ICanHas.hasPushClosures = []
                        
                        let _ = array.map{$0(authorized:authorized)}
                        
                        ICanHas.isHasingPush = false
                    }
                    
                    let application:UIApplication! = UIApplication.sharedApplication()
                    
                    if ICanHas.didTryToRegisterForPush {
                        done(application.isRegisteredForRemoteNotifications())
                    }else {
                        ICanHas.didTryToRegisterForPush = true
                        
                        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: types, categories: nil))
                        
                        var bgNoteObject:NSObjectProtocol? = nil
                        var fgNoteObject:NSObjectProtocol? = nil
                        
                        var hasTimedOut = false
                        
                        var hasGoneToBG = false
                        
                        var shouldWaitForFG = false
                        
                        bgNoteObject = bgNoteObject ?? NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillResignActiveNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (note:NSNotification) -> Void in
                            
                            hasGoneToBG = true
                            
                            if !hasTimedOut {
                                shouldWaitForFG = true
                            }
                            
                            bgNoteObject = nil
                        }
                        
                        fgNoteObject = fgNoteObject ?? NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (note:NSNotification) -> Void in
                            
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
    
    private static var locationExchangeDone:[String:Bool] = [:]
    
    public class func LocationAuthorizationStatus()->CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    
    public class func LocationAuthorization(background:Bool = false)->Bool {
        return CLLocationManager.authorizationStatus() == .AuthorizedAlways || (!background && CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse)
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
                    
                    let _ = array.map{$0(authorized:authorized,status:status)}
                    
                    ICanHas.isHasingLocation = false
                }
                
                let currentStatus = CLLocationManager.authorizationStatus()
                let callback = {(authorized:Bool) -> Void in
                    done(authorized, currentStatus)
                }
                
                
                switch currentStatus {
                case .AuthorizedAlways:
                    print("status is always")
                    callback(true)
                case .Denied:
                    print("status is denied")
                    callback(false)
                case .Restricted:
                    print("status is restricted")
                    callback(false)
                case .AuthorizedWhenInUse:
                    print("status is when in use")
                    if background {
                        fallthrough
                    }else {
                        callback(true)
                    }
                case .NotDetermined:
                    print("status is not determined")
                    var manager:CLLocationManager! = mngr ?? CLLocationManager()
                    
//                    let managerDelegate:CLLocationManagerDelegate
//                    var retainedManagerDelegate:CLLocationManagerDelegate!
                    
//                    if manager.delegate == nil {
//                        managerDelegate = _ICanHasEmptyLocationDelegate()
//                        manager.delegate = managerDelegate
//                    }else {
//                        managerDelegate = manager.delegate!
//                    }
                    
//                    retainedManagerDelegate = managerDelegate
                    
//                    let _ = retainedManagerDelegate
                    
//                    let managerDelegateClass:AnyClass = (managerDelegate as AnyObject).dynamicType
                    
//                    let managerDelegateClassName = "\(managerDelegateClass)"
                    
//                    if !(self.locationExchangeDone[managerDelegateClassName] ?? false) {
//                        self.locationExchangeDone[managerDelegateClassName] = true
//                        
//                        let pair = ("locationManager:didChangeAuthorizationStatus:","_ICanHas_locationManager:didChangeAuthorizationStatus:")
//                        
//                        if String.fromCString(method_getTypeEncoding(class_getInstanceMethod(managerDelegateClass, Selector(stringLiteral: pair.0)))) == nil {
//                            
//                            let method = class_getInstanceMethod(NSObject.self, Selector(stringLiteral:"_ICanHas_empty_" + pair.0))
//                            
//                            class_addMethod(managerDelegateClass, Selector(stringLiteral:pair.0), method_getImplementation(method), method_getTypeEncoding(method))
//                            
//                        }
//                        
//                        
//                        method_exchangeImplementations(
//                            class_getInstanceMethod(managerDelegateClass,Selector(stringLiteral: pair.0)),
//                            class_getInstanceMethod(managerDelegateClass,Selector(stringLiteral: pair.1))
//                        )
//                        
//                    }
                    
//                    var listener:_ICanHasListener! = _ICanHasListener()
//                    var removeListener:(()->Void)! = nil
                    
                    var foregroundObject:NSObjectProtocol!
                    var backgroundObject:NSObjectProtocol!
                    
                    var completed = false
                    var hasTimedOut = false
                    var canTimeOut = true
                    
                    let complete:(Bool)->Void = {
                        worked in
//                        retainedObjects = nil
//                        listener = nil
                        
                        if !completed {
                            completed = true
                            
                            manager = nil
                            
                            if let object = foregroundObject {
                                NSNotificationCenter.defaultCenter().removeObserver(object)
                            }
                            
                            if let object = backgroundObject {
                                NSNotificationCenter.defaultCenter().removeObserver(object)
                            }
                            
                            foregroundObject = nil
                            backgroundObject = nil
                            
                            let status = CLLocationManager.authorizationStatus()
                            
                            if status == .AuthorizedAlways || (!background && status == .AuthorizedWhenInUse) {
                                done(worked && true,status)
                            }else {
                                done(false,status)
                            }
                            
                        }
                        
                        
                    }
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(1 * Double(NSEC_PER_SEC))),dispatch_get_main_queue(), {
                        if canTimeOut {
                            hasTimedOut = true
                            if let object = backgroundObject {
                                NSNotificationCenter.defaultCenter().removeObserver(object)
                                backgroundObject = nil
                                complete(false)
                            }
                        }
                    })
                    
                    backgroundObject = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillResignActiveNotification, object: nil, queue: nil) {
                        _ in
                        
                        canTimeOut = false
                        
                    }
                    
                    foregroundObject = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: nil) {
                        _ in
                        
                        if !hasTimedOut {
                            complete(true)
                        }
                        
                    }
                    
//                    if let delegate = manager.delegate {
//                        var lastDelegate:NSObject = delegate as! NSObject
//                        var retainedObjects:[AnyObject]! = []
//                        retainedObjects.append(lastDelegate)
//                        while lastDelegate._ich_listener != nil {
//                            lastDelegate = lastDelegate._ich_listener
//                            retainedObjects.append(lastDelegate)
//                        }
//                        lastDelegate._ich_listener = listener
//                        
//                    }else {
//                        manager.delegate = listener
//                        removeListener = {
//                            manager.delegate = nil
//                            listener = nil
//                            manager = nil
//                            removeListener = nil
//                        }
//                    }
                    
                    
//                    listener.changedLocationPermissions = {
//                        (status:CLAuthorizationStatus) -> Void in
//                        
//                        ICanHas.onMain {
//                            if status != .NotDetermined && status != currentStatus {
//                                
//                                removeListener()
//                                
//                                
//                            }
//                        }
//                    }
                    
                    if background {
                        assert(
                            NSBundle.mainBundle().objectForInfoDictionaryKey(
                                "NSLocationAlwaysUsageDescription"
                                ) != nil,
                            "Make sure to add the key 'NSLocationAlwaysUsageDescription' to your info.plist file!"
                        )
                        
                        manager.requestAlwaysAuthorization()
                    }else {
                        
                        print("RIGHT NOW REQUESTING!!!!!")
                        
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

extension NSObject {
    
//    private var _ich_listener:_ICanHasListener! {
//        set {
//            
//            objc_setAssociatedObject(self, &_ICanHasListenerHandler, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//        }
//        get {
//            return objc_getAssociatedObject(self, &_ICanHasListenerHandler) as? _ICanHasListener
//        }
//    }
    
//    //Empty implementations:
    //Added implementations
//    public func _ICanHas_empty_locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) { }
    
//    public func _ICanHas_empty_application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) { }
//    
//    public func _ICanHas_empty_application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) { }
    
    //Added implementations
//    public func _ICanHas_locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
//        self._ich_listener!.locationManager(manager, didChangeAuthorizationStatus: status)
//        
//        print("DID CHANGE BEING CALLED!!!!")
//        
//        self._ICanHas_locationManager(manager, didChangeAuthorizationStatus: status)
//    }
    
//    public func _ICanHas_application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
//        self._ich_listener?.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
//        
//        self._ICanHas_application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
//    }
//    
//    public func _ICanHas_application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
//        self._ich_listener?.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
//        
//        self._ICanHas_application(application, didFailToRegisterForRemoteNotificationsWithError: error)
//    }
    
}

//public class _ICanHasEmptyLocationDelegate:NSObject, CLLocationManagerDelegate {
//    public func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
//        
//        print("CHANGED AUTH STATUS")
//        
//    }
//}

//public class _ICanHasListener:NSObject,CLLocationManagerDelegate,UIApplicationDelegate {
//    var changedLocationPermissions:((CLAuthorizationStatus)->Void)!
//    var registeredForPush:((NSData)->Void)!
//    var failedToRegisterForPush:((NSError)->Void)!
//    
//    public func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
//        self.changedLocationPermissions?(status)
//    }
//    
////    public func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
////        self.registeredForPush?(deviceToken)
////    }
////    public func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
////        self.failedToRegisterForPush?(error)
////    }
//}
