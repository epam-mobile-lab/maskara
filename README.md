# Maskara library
[![GitHub](https://img.shields.io/github/license/epam-mobile-lab/maskara.svg)]() [![CocoaPods](https://img.shields.io/cocoapods/v/Maskara.svg)]() [![Carthage](https://img.shields.io/badge/Carthage-1.0-brightgreen.svg)]()

Maskara library provides MaskedTextField class, subclass of UITextField which allows to control user input with generalized masked editor.

## Examples
The project contains a bunch of unit tests illustrating underlying concept as well as example project: an iOS app, which demonstrates masked editing coupled with UITextField.

### Text editor ready to be used in UITextField
```swift
let mask = "+?7|8(DDD)DDD-?DD-?DD"
var editor = try MaskedTextEditor(maskPattern: mask)
let position = try editor.replace(from: 0, length: 0, replacementString: "+7(123)456-78-90")
editor.text // "+7(123)456-78-90"
editor.extractedText // .complete("1234567890")
position // 16
```

### Advanced text matching
```swift
let allowedSymbolTokens: [Character] = ["$", ".", " ", "-", "+"]
let moneyMaskParser = try! MaskParser(pattern: "-|+?$DDD ?DDD.|D?D?D?", allowedSymbolTokens: allowedSymbolTokens)
let matcher = MaskMatcher(mask: Mask(with: moneyMaskParser.program), options: [.optimisticMatch])

var matchResult = try matcher.match(sample: "$123 123.11") // .complete
matchResult = try matcher.match(sample: "$123123.1") // .complete
matchResult = try matcher.match(sample: "$123") // .partial
matchresult = try matcher.match(sample: "-$123123") // .complete

matchResult = try matcher.match(sample: "$123(123).11") // illegal, exception thrown
```

## Base classes and interfaces

### Mask class
Base class which allows sample matching in accordance with mask set as simple state machine program. Its base method `onChar(_:)` changes the state of the state machine, which allows to check if the symbol tested matches its position.

It is not recommended to use `Mask` directly. To simplify mask creation there is `TextualMask` class inherited from `Mask`.

### TextualMask class
Textual mask allows to create an object of `Mask` class using textual representation of mask. Textual mask is being compiled into an automata during object initialisation.

Allowed mask symbols:
- `D` - numeric
- `X` - letter
- `?` - being preceded by any other valid expression makes it optional
- `|` - being placed between two valid expressions makes them conditional. If left part does not match a character tested, there will be right part tested. Otherwise, the result of evaluation of the left part will be returned.
- Symbols set as `allowedSymbolTokens` initialiser parameter will be treated “as is”. Default set is `["+", "-", " ", "(", ")"]`.

**Mask examples**

- `"D"` matches `"1", "2", "0"` etc., i.e. string containing single numeric character. Does not match `"0.1", -1, +2`.
- `"X"` matches `"A", "b", "X"` etc., string containing single latin letter character. Does not match `"Ы", " ", "?"` etc.
- `"D?"` matches `"1", "2",` etc. and `""`, i.e. string containing single numeric character or an empty string.
- `"DD?` matches `"11", "01", "1", "9"` etc., i.e. string containing one or two numeric characters.
- `"7|8"` matches `"7"` and `"8"` strings. All other strings do not match.
- `"7|8|9` matches `"7"`, `"8"` and `"9"` strings. All other strings do not match.
- `"-| "` matches `"-"` and `" "`, i.e. space character.
- `"-| ?"` matches `"-"`, `" "` and an empty string.

And now let us combine them all: mask `"+?7|8(DDD)DDD-| ?DD-| ?D|XD|X"` will match following sample strings: `""+7(123)456-78-90"`, `"8(123)456 78 90"`, `"7(123)4567890"` and `"7(123)45678-OK"`. But mask `"+7(DDD)DDD-DD-DD"` will only match strings like `"+7(812)123-45-67"` or `"+7(000)000-00-00"`.

### MaskMatcher class
`MaskMatcher` class provides high level service functions for handling samples using mask:
- `match(sample:,resetMask:) throws` - returns `MatchResult` enum which is the result of testing of a sample string or throws.
- `transform(sample:,resetMask:) throws` - returns a `String` which is the result of combining a sample given and the mask
- `extract(from:,resetMask:)` - returns an `ExtractResult` enum which is the result of extracting meaningful symbols from [transformed] sample string.

## User interface
### MaskedTextEditor class
`MaskedTextEditor` incapsulates all the details of editing the text field being controlled by mask. It does not depend on any UI framework, but it has interface which is suited for integration with UIKit (at the moment).

### MaskedTextField class
`MaskedTextField: UITextField` contains an instance of `MaskedTextEditor` and supports strightforward interface for editing and getting data. Please refer the example included for the details.

## Roadmap

What we are going to add soon:
- CocoaPods integration
- Swift Package Manager
- SwiftUI integration
- Examples of integration with great [PhoneNumberKit](https://github.com/marmelroy/PhoneNumberKit) framework

## Installation

### Cocoapods
```
  Coming soon
```
<!--
```
  pod 'Maskara', '~> 1.0.0'
```
-->
### Carthage
```
  github "epam-mobile-lab/maskara" == 1.0.0
```
### Swift Package Manager
```
  Coming soon
```
<!--
```
```
-->
