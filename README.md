# ICanHas
Swift 4 library that simplifies iOS user permission requests (push notifications, location, camera, photo library, contacts, calendar).

## Installation

Just add ICanHas.swift to your Xcode project (I know, I know).

## Usage

Use the provided method every time you need to make sure that the app has permissions to access the corresponding service. The first time a function is called, it may prompt the user to allow that service on a native alert view. See the examples below

### Location:
```swift
ICanHas.location { authorized, status in
    print(authorized ? "You're authorized to use location!" : "You're not authorized to use location!")
}
```
💡 You may specify whether you would like the app to be able to access location while in the background, and/or the location manager you will be using, as follows:
```swift
let myManager = CLLocationManager()
ICanHas.location(background: false, manager: myManager) { ... }
```
💡 Also make sure to add the `NSLocationWhenInUseUsageDescription` or `NSLocationAlwaysUsageDescription` key to your `Info.plist` file. [More info here](https://developer.apple.com/library/content/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html).

### Push Notifications:
```swift
ICanHas.push { authorized in
    print(authorized ? "You're authorized to send push notes!" : "You're not authorized to send push notes!")
}
```
💡 This function has one optional parameter `types: UIUserNotificationType` which specifies the user notification types for which you would like the app to be registered. The default value includes all types `[.alert, .badge, .sound]`.

💡 For this authorization to work, you will need to run your app on a device (the simulator cannot register for push notifications) and make sure you have all the necessary provisioning and certificates. [More info here](http://help.apple.com/xcode/mac/current/#/dev11b059073).


### Calendar:
```swift
ICanHas.calendar { authorized, status, error in
    print(authorized ? "You're authorized to access the calendar!" : "You're not authorized to access the calendar!")
}
```
💡 You may optionally specify an `EKEventStore` and/or an entity type. For example:
```swift
let myStore = EKEventStore()
ICanHas.calendar(store: myStore, type: .event) { ... }
```

### Capture (Camera, Microphone, etc):
```swift
ICanHas.capture { authorized, status in
    print(authorized ? "You're authorized to access the camera!" : "You're not authorized to access the camera!")
}
```
💡 To request access to the microphone use the optional `type` parameter: `ICanHas.capture(type: .audio) { ... }`. See `AVMediaType` for other available types.

### Photos (Library):
```swift
ICanHas.photos { authorized, status in
    print(authorized ? "You're authorized to access photos!" : "You're not authorized to access photos!")
}
```

### Contacts:
```swift
ICanHas.contacts { authorized, status, error in
    print(authorized ? "You're authorized to access contacts!" : "You're not authorized to access contacts!")
}
```
💡 You may optionally specify the address book reference you would like to use:
```swift
let addressBook = ABAddressBookCreateWithOptions(nil, nil)?.takeRetainedValue()
ICanHas.contacts(addressBook: addressBook) { ... }
```

## License

ICanHas is available under the MIT license. See the LICENSE file for more info.

