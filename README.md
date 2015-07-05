# ICanHas
Swift library that simplifies iOS user permission requests (location, push notifications, camera, contacts, calendar, photos, etc).

## Installation

Just add ICanHas.swift to your Xcode project.

## Usage

See example below. More specific documentation coming soon.

```swift
ICanHas.Location { (authorized, status) -> Void in
    println(authorized ? "You're authorized to use location!" : "You're not authorized to use location!")
}
```
