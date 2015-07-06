# ICanHas
Swift library that simplifies iOS user permission requests (location, push notifications, camera, contacts, calendar, photos, etc).

**The library is still in early stage so please don't hesitate to give suggestions or report issues.**

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

### Push Notifications:
```swift
ICanHas.Push { (authorized) -> Void in
    println(authorized ? "You're authorized to send push notes!" : "You're not authorized to send push notes!")
}
```
**Remark:** This function has one optional parameter `types:UIUserNotificationType` which specifies the user notification types for which you would like the app to be registered. The default value includes all types `.Alert|.Badge|.Sound`. **To specify this parameters, write `ICanHas.Push(types:...) { ... }`.**

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

Other available functions are `ICanHas.Contacts`, `ICanHas.Capture`, and `ICanHas.Photos`. Some of them take some optional parameters (you may omit them) before the closure.


