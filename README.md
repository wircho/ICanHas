# ICanHas
Swift library that simplifies iOS user permission requests (location, push notifications, camera, contacts, calendar, photos, etc).

This library is part of our project to open source some of the code base for the **[Relevant iOS App](https://itunes.apple.com/app/relevant-missing-home-screen/id970172407?ls=1&mt=8)**. Visit **[relevant.ai](http://relevant.ai)** for more information.

**The library is still in early stage so please don't hesitate to give us suggestions or report issues.**

## Installation

Just add ICanHas.swift to your Xcode project.

## Usage

Use the provided function every time you need to make sure that the app has permissions to access the corresponding service. The first time a function is called, it may prompt the user to allow that service on a native alert view. See the examples below

### Location:
```swift
ICanHas.Location { (authorized, status) -> Void in
    println(authorized ? "You're authorized to use location!" : "You're not authorized to use location!")
}
```
**Remark:** You may specify whether you would like the app to be able to access location while in the background, and/or the location manager you will be using, as follows:
```swift
let myManager = CLLocationManager()
ICanHas.Location(background:false,manager:myManager) { ... }
```
**Remark:** Also make sure to add the `NSLocationWhenInUseUsageDescription` or `NSLocationAlwaysUsageDescription` key to your `Info.plist` file. Not doing so will produce an assertion failure. [More info here](https://developer.apple.com/library/prerelease/ios/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW18).

### Push Notifications:
```swift
ICanHas.Push { (authorized) -> Void in
    println(authorized ? "You're authorized to send push notes!" : "You're not authorized to send push notes!")
}
```
**Remark:** This function has one optional parameter `types:UIUserNotificationType` which specifies the user notification types for which you would like the app to be registered. The default value includes all types `.Alert|.Badge|.Sound`. **To specify this parameters, write `ICanHas.Push(types:...) { ... }`.**
**Remark:** For this authorization to work, you will need to run your app on a device (the simulator cannot register for push notifications) and make sure you have all the necessary provisioning and certificates. [More info here](https://developer.apple.com/library/ios/documentation/IDEs/Conceptual/AppDistributionGuide/ConfiguringPushNotifications/ConfiguringPushNotifications.html).


### Calendar:
```swift
ICanHas.Calendar { (authorized,error) -> Void in
    println(authorized ? "You're authorized to access the calendar!" : "You're not authorized to access the calendar!")
}
```
**Remark:** You may optionally specify an EKEventStore and/or an entity type. For example:
```swift
let myStore = EKEventStore()
ICanHas.Calendar(store:myStore,entityType:EKEntityTypeEvent) { ... }
```

### Capture (Camera, Microphone, etc):
```swift
ICanHas.Capture { (authorized,status) -> Void in
    println(authorized ? "You're authorized to access the camera!" : "You're not authorized to access the camera!")
}
```
**Remark:** To request access to the microphone use the optional `type` parameter: `ICanHas.Capture(type:AVMediaTypeAudio) { ... }`. Other available types are `AVMediaTypeClosedCaption, AVMediaTypeMetadata, AVMediaTypeMuxed, AVMediaTypeSubtitle, AVMediaTypeText, AVMediaTypeTimecode`. Default is `AVMediaTypeVideo`.

### Photos (Albums):
```swift
ICanHas.Photos { (authorized,status) -> Void in
    println(authorized ? "You're authorized to access photos!" : "You're not authorized to access photos!")
}
```

### Contacts:
```swift
ICanHas.Contacts { (authorized,status,error) -> Void in
    println(authorized ? "You're authorized to access contacts!" : "You're not authorized to access contacts!")
}
```
**Remark:** You may optionally specify the address book reference you would like to use:
```swift
let myAddressBookRef = ABAddressBookCreateWithOptions(nil, nil)?.takeRetainedValue()
ICanHas.Contacts(addressBook:myAddressBookRef) { ... }
```


