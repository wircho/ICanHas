# ICanHas
Swift library that simplifies iOS user permission requests (location, push notifications, camera, contacts, calendar, photos, etc).

**The library is still in early stage so please don't hesitate to give suggestions or report issues.**

## Installation

Just add ICanHas.swift to your Xcode project.

## Usage

Use the provided function every time you need to make sure that you have permissions to access the corresponding service. The first time the function is called, it may prompt the user to allow that service on a native alert view. See the example below

```swift
ICanHas.Location { (authorized, status) -> Void in
    println(authorized ? "You're authorized to use location!" : "You're not authorized to use location!")
}
```

Other available functions are `ICanHas.Contacts`, `ICanHas.Calendar`, `ICanHas.Capture`, `ICanHas.Push`, and `ICanHas.Photos`. Some of them take some optional parameters (you may omit them) before the closure.


