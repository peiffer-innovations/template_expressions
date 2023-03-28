## [2.2.3+3] - March 28, 2023

* Automated dependency updates


## [2.2.3+2] - March 21, 2023

* Automated dependency updates


## [2.2.3+1] - March 19th, 2023

* Upgraded to `json_path` to 0.4.4 which resolved the `petitparser` issue.


## [2.2.3] - March 18th, 2023

* Locked `json_path` to 0.4.2 because 0.4.3 requires `petitparser` 5.2.0 or above and... the petitparser issue below remains.


## [2.2.2] - March 13th, 2023

* Locked `petitparser` to 5.1.0 until one of these is actually resolved:
    * https://github.com/flutter/flutter/issues/121391
    * https://github.com/petitparser/dart-petitparser/issues/144


## [2.2.1+4] - March 7, 2023

* Automated dependency updates


## [2.2.1+3] - February 21, 2023

* Automated dependency updates


## [2.2.1+2] - February 14, 2023

* Automated dependency updates


## [2.2.1+1] - January 31, 2023

* Automated dependency updates


## [2.2.1] - January 24th, 2023

* Dart 2.19


## [2.2.0+2] - January 17, 2023

* Automated dependency updates


## [2.2.0+1] - January 3, 2023

* Automated dependency updates


## [2.2.0] - December 31st, 2022

* Added `evaluate` and `evaluateAsync` to evaluate a template into a dynamic result rather than a string one


## [2.1.0+1] - December 27, 2022

* Automated dependency updates


## [2.1.0] - December 25th, 2022

* Assed `CustomizableMemberAccessor`
* Added `delay` as a synonym to `delayed`
* Added `Logger` functions
* Added `processAsync` to the Template
* Added support for `delayed` as a function
* Added ability to pass in the member accessors for parsing templates
* Added `onValueChanged` and support for the assignment operator to assign values as part of expressions


## [2.0.0+4] - December 20, 2022

* Automated dependency updates


## [2.0.0+3] - December 13, 2022

* Automated dependency updates


## [2.0.0+2] - November 22, 2022

* Automated dependency updates


## [2.0.0+1] - November 15, 2022

* Automated dependency updates


## [2.0.0] - November 12th, 2022

* Updated to require petitparser 5+


## [1.1.7+11] - November 8, 2022

* Automated dependency updates


## [1.1.7+10] - October 18, 2022

* Automated dependency updates


## [1.1.7+9] - October 11, 2022

* Automated dependency updates


## [1.1.7+8] - September 13, 2022

* Automated dependency updates


## [1.1.7+7] - September 6, 2022

* Automated dependency updates


## [1.1.7+6] - July 28th, 2022

* Revert crypto


## [1.1.7+5] - July 26, 2022

* Automated dependency updates


## [1.1.7+4] - July 19, 2022

* Automated dependency updates


## [1.1.7+3] - July 12, 2022

* Automated dependency updates


## [1.1.7+2] - June 28, 2022

* Automated dependency updates


## [1.1.7+1] - June 21, 2022

* Automated dependency updates


## [1.1.7] - June 16th, 2022

* Fix for escapeing backslash (`\\`)
* Added `base64url` to `Codec` and `.toBase64Url()` to `List<int>`


## [1.1.6+2] - May, 31, 2022

* Automated dependency updates


## [1.1.6+1] - May 14th, 2022


## [1.1.5+1] - April 18th, 2022

* Added `AES` and `RSA` for encryption and description
* Added pointycastle dependency
* Added `toJson` functions to both `Map` and `List`


## [1.1.4] - April 16th, 2022

* Fixed duration_functions to return milliseconds rather than microseconds
* Added `random` function
* Added `hmac`, `md5`, `sha256`, and `sha512` functions


## [1.1.3] - April 5th, 2022

* Better logging on exceptions in the template


## [1.1.2+2] - April 4th, 2022

* Updated to be null friendly and not throw exceptions when attempting to access against null values


## [1.1.1+1] - March 27th, 2022

* Removed undocumented `value` function


## [1.1.0+3] - March 27th, 2022

* Moved the standard functions from the template to the expressions itself
* Dart 2.16


## [1.0.1+1] - March 5th, 2022

* Added `Codex` built in type


## [1.0.0] - February 26th, 2022

* Initial Release
























