# Maskara library
Maskara library provides MaskedTextField class, subclass of UITextField which allows to control user input with generalized masked editor.

## Examples
The project contains a bunch of unit tests illustrating underlying concept as well as example project: an iOS app, which demonstrates masked editing coupled with UITextField.

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

### Text editor ready to be used in UITextField
```swift
let mask = "+?7|8(DDD)DDD-?DD-?DD"
var editor = try MaskedTextEditor(maskPattern: mask)
let position = try editor.replace(from: 0, length: 0, replacementString: "+7(123)456-78-90")
editor.text // "+7(123)456-78-90"
editor.extractedText // "1234567890"
position // 16
```

## Base classes and interfaces

### Mask class
Base class which allows sample mathcing in accordance with mask set as simple state machine program. It’s base method `onChar(_:)` changes the state of the state machine, which allows to check if the symbol tested matches its position.

It is discouraged to use `Mask` directly. To simplify mask creation there is `TextualMask` class inherited from `Mask`.

### TextualMask class
Textual mask allows to create an object of `Mask` class using textual representation of mask. Textual mask is being compiled into an automata during object initialization.

Allowed mask symbols:
- `D` - numeric
- `X` - letter
- `?` - being preceded by any other valid expression makes it optional
- `|` - being placed between two valid expressions makes them conditional. If left part does not match a character tested, there will be right part tested. Otherwise, the result of evaluation of the left part will be returned.
- Symbols set as `allowedSymbolTokens` initializer parameter will be treated “as is”. Default set is `["+", "-", " ", "(", ")"]`.

For example, `+?7|8(DDD)DDD-| ?DD-| ?D|XD|X` will match following sample strings: `+7(123)456-78-90`, `8(123)456 78 90`, `7(123)4567890` and `7(123)45678-OK`.

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

## Installation

### Cocoapods
```
  pod 'Maskara', '~> 1.0.0'
```
### Carthage
```
github "epam-mobile-lab/maskara" == 1.0.0
```


