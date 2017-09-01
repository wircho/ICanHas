import Foundation

import UIKit

import CoreLocation

import AVFoundation

import Photos

import AddressBookUI

import EventKit

public typealias AuthClosure = (_ authorized: Bool) -> Void
public typealias AuthErrorClosure = (_ authorized: Bool, _ error: Error?) -> Void
public typealias AuthStatusClosure<Status> = (_ authorized: Bool, _ status: Status) -> Void
public typealias AuthStatusErrorClosure<Status> = (_ authorized: Bool, _ status: Status, _ error: Error?) -> Void

private func complete(_ closures: inout [AuthClosure], _ flag: inout Bool, _ authorized: Bool) {
    let array = closures
    closures = []
    for closure in array { closure(authorized) }
    flag = true
}

private func complete(_ closures: inout [AuthErrorClosure], _ flag: inout Bool, _ authorized: Bool, error: Error?) {
    let array = closures
    closures = []
    for closure in array { closure(authorized, error) }
    flag = true
}

private func complete<Status>(_ closures: inout [AuthStatusClosure<Status>], _ flag: inout Bool, _ authorized: Bool, _ status: Status) {
    let array = closures
    closures = []
    for closure in array { closure(authorized, status) }
    flag = true
}

private func complete<Status>(_ closures: inout [AuthStatusErrorClosure<Status>], _ flag: inout Bool, _ authorized: Bool, _ status: Status, _ error: Error?) {
    let array = closures
    closures = []
    for closure in array { closure(authorized, status, error) }
    flag = true
}

private func observeOnce(notificationName: Notification.Name, queue: OperationQueue = .main, using closure: @escaping (Notification) -> Void) {
    var observerObject: NSObjectProtocol?
    observerObject = NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: queue) {
        note in
        guard let object = observerObject else { return }
        observerObject = nil
        NotificationCenter.default.removeObserver(object)
        closure(note)
    }
}

open class ICanHas {
    
    fileprivate class func onMain(_ closure: @escaping () -> Void) { DispatchQueue.main.async(execute: closure) }
    
    static private var didTryToRegisterForPush = false
    
    static private var isHasingPush = false
    static private var isHasingLocation = false
    static private var isHasingCapture: [AVMediaType: Bool] = [:]
    static private var isHasingPhotos = false
    static private var isHasingContacts = false
    static private var isHasingCalendar: [EKEntityType: Bool] = [:]
    static private var hasPushClosures: [AuthClosure] = []
    static private var hasLocationClosures: [AuthStatusClosure<CLAuthorizationStatus>] = []
    static private var hasCaptureClosures: [AVMediaType: [AuthStatusClosure<AVAuthorizationStatus>]] = [:]
    static private var hasPhotosClosures: [AuthStatusClosure<PHAuthorizationStatus>] = []
    static private var hasContactsClosures: [AuthStatusErrorClosure<ABAuthorizationStatus>] = []
    static private var hasCalendarClosures: [EKEntityType: [AuthStatusErrorClosure<EKAuthorizationStatus>]] = [:]
    
    open class func calendarAuthorizationStatus(for type: EKEntityType = EKEntityType.event) -> EKAuthorizationStatus {
        return EKEventStore.authorizationStatus(for: type)
    }
    
    open class func calendarAuthorization(for type: EKEntityType = EKEntityType.event) -> Bool {
        return calendarAuthorizationStatus(for: type) == .authorized
    }
    
    open class func calendar(store: EKEventStore = EKEventStore(), type: EKEntityType = .event, closure: @escaping AuthStatusErrorClosure<EKAuthorizationStatus>) {
        onMain {
            hasCalendarClosures[type, default: []].append(closure)
            guard !isHasingCalendar[type, default: false] else { return }
            isHasingCalendar[type] = true
            let done: AuthStatusErrorClosure<EKAuthorizationStatus> = { authorized, status, error in
                complete(&hasCalendarClosures[type, default: []], &isHasingCalendar[type, default: false], authorized, status, error)
            }
            let status = calendarAuthorizationStatus(for: type)
            switch status {
            case .denied, .restricted: done(false, status, nil)
            case .authorized: done(true, status, nil)
            case .notDetermined:
                store.requestAccess(to: type) { authorized, error in
                    onMain { done(authorized, calendarAuthorizationStatus(for: type), error) }
                }
            }
        }
    }
    
    open class func contactsAuthorizationStatus() -> ABAuthorizationStatus {
        return ABAddressBookGetAuthorizationStatus()
    }
    
    open class func contactsAuthorization() -> Bool {
        return contactsAuthorizationStatus() == .authorized
    }
    
    open class func contacts(book: ABAddressBook? = ABAddressBookCreateWithOptions(nil, nil)?.takeRetainedValue(), closure: @escaping AuthStatusErrorClosure<ABAuthorizationStatus>) {
        onMain {
            hasContactsClosures.append(closure)
            guard !isHasingContacts else { return }
            isHasingContacts = true
            let done: AuthStatusErrorClosure<ABAuthorizationStatus> = { authorized, status, error in
                complete(&hasContactsClosures, &isHasingContacts, authorized, status, error)
            }
            let status = contactsAuthorizationStatus()
            switch status {
            case .denied, .restricted: done(false, status, nil)
            case .authorized: done(true, status, nil)
            case .notDetermined:
                ABAddressBookRequestAccessWithCompletion(book) { authorized, error in
                    onMain { done(authorized, contactsAuthorizationStatus(), error) }
                }
            }
        }
        
    }
    
    open class func photosAuthorizationStatus() -> PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus()
    }
    
    open class func photosAuthorization() -> Bool {
        return photosAuthorizationStatus() == .authorized
    }
    
    open class func photos(closure: @escaping AuthStatusClosure<PHAuthorizationStatus>) {
        onMain {
            hasPhotosClosures.append(closure)
            guard !isHasingPhotos else { return }
            isHasingPhotos = true
            let done: AuthStatusClosure<PHAuthorizationStatus> = { authorized, status in
                complete(&hasPhotosClosures, &isHasingPhotos, authorized, status)
            }
            let status = photosAuthorizationStatus()
            switch status {
            case .denied, .restricted: done(false, status)
            case .authorized: done(true, status)
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { status in
                    onMain { done(status == .authorized, status) }
                }
            }
        }
        
    }
    
    open class func captureAuthorizationStatus(for type: AVMediaType = .video) -> AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: type)
    }
    
    open class func captureAuthorization(for type: AVMediaType = .video) -> Bool {
        return captureAuthorizationStatus(for: type) == .authorized
    }
    
    open class func capture(_ type: AVMediaType = .video, closure: @escaping AuthStatusClosure<AVAuthorizationStatus>) {
        onMain {
            hasCaptureClosures[type, default: []].append(closure)
            guard !isHasingCapture[type, default: false] else { return }
            isHasingCapture[type] = true
            let done: AuthStatusClosure<AVAuthorizationStatus> = { authorized, status in
                complete(&hasCaptureClosures[type, default: []], &isHasingCapture[type, default:false], authorized, status)
            }
            let status = captureAuthorizationStatus(for: type)
            switch status {
            case .denied, .restricted: done(false, status)
            case .authorized: done(true, status)
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: type) { authorized in
                    onMain { done(authorized, captureAuthorizationStatus(for: type)) }
                }
            }
        }
    }
    
    open class func pushAuthorization() -> Bool {
        return UIApplication.shared.isRegisteredForRemoteNotifications
    }
    
    open class func push(_ types: UIUserNotificationType = [.alert, .badge, .sound], closure: @escaping AuthClosure) {
        onMain {
            hasPushClosures.append(closure)
            guard !isHasingPush else { return }
            isHasingPush = true
            let done: AuthClosure = { authorized in
                complete(&hasPushClosures, &isHasingPush, authorized)
            }
            let application = UIApplication.shared
            guard !didTryToRegisterForPush else {
                done(application.isRegisteredForRemoteNotifications)
                return
            }
            didTryToRegisterForPush = true
            
            application.registerUserNotificationSettings(UIUserNotificationSettings(types: types, categories: nil))
            
            var hasTimedOut = false
            var hasGoneToBackground = false
            var waitingForForeground = false
            
            observeOnce(notificationName: .UIApplicationWillResignActive) { _ in
                hasGoneToBackground = true
                waitingForForeground = !hasTimedOut || waitingForForeground
            }
            
            observeOnce(notificationName: .UIApplicationDidBecomeActive) { _ in
                guard waitingForForeground else { return }
                done(application.isRegisteredForRemoteNotifications)
            }
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                hasTimedOut = true
                guard !hasGoneToBackground else { return }
                done(application.isRegisteredForRemoteNotifications)
            }
            
            application.registerForRemoteNotifications()
        }
    }
    
    open class func locationAuthorizationStatus() -> CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    
    open class func locationAuthorization(background: Bool = false) -> Bool {
        let status = locationAuthorizationStatus()
        return status == .authorizedAlways || (!background && status == .authorizedWhenInUse)
    }
    
    open class func location(_ background: Bool = false, manager defaultManager: CLLocationManager? = nil, closure: @escaping AuthStatusClosure<CLAuthorizationStatus>) {
        onMain {
            hasLocationClosures.append(closure)
            guard !isHasingLocation else { return }
            ICanHas.isHasingLocation = true
            let done: AuthStatusClosure<CLAuthorizationStatus> = { authorized, status in
                complete(&hasLocationClosures, &isHasingLocation, authorized, status)
            }
            let status = locationAuthorizationStatus()
            switch status {
            case .authorizedAlways: done(true, status)
            case .denied, .restricted: done(false, status)
            case .authorizedWhenInUse:
                guard !background else { fallthrough }
                done(true, status)
            case .notDetermined:
                var manager: CLLocationManager? = defaultManager ?? CLLocationManager()
                
                var completed = false
                var hasTimedOut = false
                var canTimeOut = true
                
                let complete: (Bool) -> Void = {
                    worked in
                    guard !completed else { return }
                    completed = true
                    manager = nil
                    done(worked && locationAuthorization(background: background), locationAuthorizationStatus())
               }
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                    guard canTimeOut else { return }
                    hasTimedOut = true
                    complete(false)
                }
                
                observeOnce(notificationName: .UIApplicationWillResignActive) { _ in canTimeOut = false }
                
                observeOnce(notificationName: .UIApplicationDidBecomeActive) { _ in
                    guard !hasTimedOut else { return }
                    complete(true)
                }
                
                manager?.requestWhenInUseAuthorization()
            }
        }
    }
}
