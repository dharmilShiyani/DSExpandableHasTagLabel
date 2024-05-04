# DSExpandableHasTagLabel

[![CI Status](https://img.shields.io/travis/dharmilShiyani/DSExpandableHasTagLabel.svg?style=flat)](https://travis-ci.org/dharmilShiyani/DSExpandableHasTagLabel)
[![Version](https://img.shields.io/cocoapods/v/DSExpandableHasTagLabel.svg?style=flat)](https://cocoapods.org/pods/DSExpandableHasTagLabel)
[![License](https://img.shields.io/cocoapods/l/DSExpandableHasTagLabel.svg?style=flat)](https://cocoapods.org/pods/DSExpandableHasTagLabel)
[![Platform](https://img.shields.io/cocoapods/p/DSExpandableHasTagLabel.svg?style=flat)](https://cocoapods.org/pods/DSExpandableHasTagLabel)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

<!--## Requirements-->

## Installation

DSExpandableHasTagLabel is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'DSExpandableHasTagLabel'
```
## Usage

Import it in the ViewController you want it to work:

```ruby
import DSExpandableHasTagLabel
```
In your viewDidLoad function, call DSExpandableHasTagLabel on self:

```ruby
let text = "Lorem ipsum dolor sit amet, consectetur @user adipiscing elit. #Innovation et lorem @urna, sed vehicula leo. Ut fermentum massa justo sit amet risus. Etiam porta sem malesuada magna mollis euismod. Donec id elit non mi"
self.lblDescription.shouldCollapse = true
self.lblDescription.textReplacementType = .word
self.lblDescription.numberOfLines = 2
self.lblDescription.expandedAttributedLink = NSAttributedString(string: "Read Less", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16.0, weight: .semibold)])
self.lblDescription.collapsedAttributedLink = NSAttributedString(string: "Read More", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16.0, weight: .semibold)])
self.lblDescription.collapsed = true
self.lblDescription.text = (obj.content ?? "").decodingEmoji().trimmingCharacters(in: .whitespacesAndNewlines)
self.lblDescription.onHashtagTapped = { hashTag in
    print("Hashtag Tapped: \(hashTag)")
}
self.lblDescription.onTagUserTapped = { mentionUser in
    print("mentionUser Tapped: \(mentionUser)")
}
```

## Author

dharmilShiyani, dharmil.official@gmail.com

## License

DSExpandableHasTagLabel is available under the MIT license. See the LICENSE file for more info.
