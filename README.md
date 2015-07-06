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
    println(authorized ? "You're authorized to use push!" : "You're not authorized to use push!")
}
```
**Remark:** This function has one optional parameter `types:UIUserNotificationType` which specifies the user notification types you would like the app to be registered. The default value includes all types `.Alert|.Badge|.Sound`. To specify this parameters, write `ICanHas.Push(types:...) {...}`.

Other available functions are `ICanHas.Contacts`, `ICanHas.Calendar`, `ICanHas.Capture`, and `ICanHas.Photos`. Some of them take some optional parameters (you may omit them) before the closure.


