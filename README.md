# template_expressions


## Table of Contents

* [Introduction](#introduction)
* [Using the Library](#using-the-library)
* [Template Expression Syntax](#template-expression-syntax)
    * [HashExpressionSyntax](#hashexpressionsyntax)
    * [MustacheExpressionSyntax](#mustacheexpressionsyntax)
    * [PipeExpressionSyntax](#pipeexpressionsyntax)
    * [StandardExpressionSyntax](#standardexpressionsyntax)
* [Built in Objects and Members](#built-in-objects-and-members)
    * [DateFormat](#dateformat)
    * [DateTime](#datetime)
    * [Duration](#duration)
    * [Iterable](#iterable)
        * [List](#list)
    * [JsonPath](#jsonpath)
    * [JsonPathMatch](#jsonpathmatch)
    * [Map](#map)
    * [num](#num)
    * [String](#string)
    * [Object](#object)

## Introduction

A Dart library to process string based templates using expressions.

## Using the Library

Add the repo to your Dart `pubspec.yaml` file.

```
dependencies:
  template_expressions: <<version>> 
```

Then run...
```
dart pub get
```

---

## Template Expression Syntax

The template engine supports different syntax options for how the expressions are discovered within the template.  There are three built in syntax options as described below.  To provide your own syntax, simple implement the [ExpressionSyntax](https://github.com/peiffer-innovations/template_expressions/blob/main/lib/src/template/expression_syntax.dart) class and pass that to the template at construction.

### HashExpressionSyntax

The hash expression syntax begins and ends with a double hash symbol.  This syntax is compatible with many different forms of code and text file templates without much need for escape characters.

**Example**

```json
{
  "firstName": "##firstName.toUpperCase()##",
  "lastName": "##lastName.toUpperCase()##"
}
```


### MustacheExpressionSyntax

The mustache expression syntax begins with a double open curly brace and ends with a double close curley brace.  This syntax is relatively common as it is a highly simplified version of the [mustache](https://mustache.github.io/mustache.5.html) template.  Only the double curly braces are supported, no other aspects of the mustache syntax are.

**Example**

```json
{
  "firstName": "{{firstName.toUpperCase()}}",
  "lastName": "{{lastName.toUpperCase()}}"
}
```


### PipeExpressionSyntax

The pipe expression syntax begins and ends with a single pipe symbol.  This syntax is compatible with many different forms of code and text file templates without much need for escape characters.

**Example**

```json
{
  "firstName": "|firstName.toUpperCase()|",
  "lastName": "|lastName.toUpperCase()|"
}
```


### StandardExpressionSyntax

The standard expression syntax follows the Dart string interpolation pattern.  This is the default syntax all templates will use unless a separate syntax list is provided.  It is the default as it is likely to be the most familiar with Dart developers, however it also has some conflicts that require special escaping.  In Dart code, either the dollar sign must be escaped `\${...}` or the string must be tagged as a regular string (`r'...'`).  In all forms, if there is a map defined in the expression, the close curly braces must be escaped like: `r'${createName({"firstName": "John", "lastName": "Smith"\})}`

**Example**

```json
{
  "firstName": "${firstName.toUpperCase()}",
  "lastName": "${lastName.toUpperCase()}"
}
```

---

## Built in Objects and Members

### DateFormat

The [DateFormat](https://pub.dev/documentation/intl/latest/intl/DateFormat-class.html) class is supported for parsing and formatting functions.

#### Constructors

```
DateFormat(String format)
```

#### Member Functions

| Function | Example |
|----------|---------|
| [format](https://pub.dev/documentation/intl/latest/intl/DateFormat/format.html) | `${DateFormat('yyyy-MM-dd').format(now())}`|
| [parse](https://pub.dev/documentation/intl/latest/intl/DateFormat/parse.html) | `${DateFormat('yyyy-MM-dd').parse('2022-01-01')}`|
| [parseUTC](https://pub.dev/documentation/intl/latest/intl/DateFormat/parseUTC.html) | `${DateFormat('yyyy-MM-dd').parseUTC('2022-01-01')}`|
| [parseUtc](https://pub.dev/documentation/intl/latest/intl/DateFormat/parseUtc.html) | `${DateFormat('yyyy-MM-dd').parseUtc('2022-01-01')}`|

---

### DateTime

The [DateTime](https://api.flutter.dev/flutter/dart-core/DateTime-class.html) class is supported for performing date time related functionality.

#### Constructors

```
now()
DateTime(int utcMillis)
DateTime(int year, int month, [int date, int hour, int minute, int second, int millisecond])
DateTime({int year, int month, int date, int hour, int minute, int second, int millisecond})
DateTime(List<int> yearMonthDateHourMinuteSecondMillisecond)
```

#### Global Functions

| Function | Description | Example |
|----------|-------------|---------|
| [now](https://api.flutter.dev/flutter/dart-core/DateTime/DateTime.now.html) | Alias for the dart code of `DateTime.now()` | `${now()}` |


#### Member Functions

| Function | Example |
|----------|---------|
| [add](https://api.flutter.dev/flutter/dart-core/DateTime/add.html) | `${now().add(minutes(5))}` |
| add(int millis) | `${now().add(30000)}` |
| [compareTo](https://api.flutter.dev/flutter/dart-core/DateTime/compareTo.html) | `${now().compareTo(other)}` | 
| [isAfter](https://api.flutter.dev/flutter/dart-core/DateTime/isAfter.html) | `${now().isAfter(other)}` |
| [isBefore](https://api.flutter.dev/flutter/dart-core/DateTime/isBefore.html) | `${now().isBefore(other)}` |
| [isUtc](https://api.flutter.dev/flutter/dart-core/DateTime/isUtc.html) | `${now().isUtc}` |
| [millisecondsSinceEpoch](https://api.flutter.dev/flutter/dart-core/DateTime/millisecondsSinceEpoch.html) | `${now().millisecondsSinceEpoch}` |
| [subtract](https://api.flutter.dev/flutter/dart-core/DateTime/subtract.html) | `${now().subtract(minutes(5))}` |
| subtract(int millis) | `${now().subtract(30000)}` |
| [toIso8601String](https://api.flutter.dev/flutter/dart-core/DateTime/toIso8601String.html) | `${now().toIso8601String()}` |
| [toLocal](https://api.flutter.dev/flutter/dart-core/DateTime/toLocal.html) | `${now().toLocal()}` |
| [toUtc](https://api.flutter.dev/flutter/dart-core/DateTime/toUtc.html) | `${now().toUtc()}` |

---

### Duration

The [Duration](https://api.flutter.dev/flutter/dart-core/Duration-class.html) class is supported for duration related calculations.

#### Constructors

```
now()
Duration(int milliseconds)
DateFormat(int days, int hours, [int minutes, int seconds, int milliseconds])
DateFormat({int days, int hours, [int minutes, int seconds, int milliseconds})
DateFormat(List<int> daysHoursMinutesSecondsMilliseconds)
```

#### Global Functions

| Function | Description | Example |
|----------|-------------|---------|
| `days(int value)` | Alias for `Duration({"days": value})` | `${days(5).inMilliseconds}` |
| `hours(int value)` | Alias for `Duration({"hours": value})`  | `${hours(5).inMilliseconds}` |
| `milliseconds(int value)` | Alias for `Duration({"milliseconds": value})`  | `${milliseconds(5000).inSeconds}` |
| `minutes(int value)` | Alias for `Duration({"minutes": value})`  | `${minutes(5).inMilliseconds}` |
| `seconds(int value)` | Alias for `Duration({"seconds": value})`  | `${seconds(5).inMilliseconds}` |


#### Member Functions

| Function | Example |
|----------|---------|
| `add(Duration duration)` | `${Duration(1000).add(minutes(5))}` |
| `add(int milliseconds)` | `${Duration(1000).add(1000)}` |
| [compareTo](https://api.flutter.dev/flutter/dart-core/Duration/compareTo.html) | `${Duration(1000).compareTo(other)}` | 
| [inDays](https://api.flutter.dev/flutter/dart-core/Duration/inDays.html) | `${Duration({"hours": 48}).inDays}` |
| [inHours](https://api.flutter.dev/flutter/dart-core/Duration/inHours.html) | `${Duration(30000).inHours}` |
| [inMilliseconds](https://api.flutter.dev/flutter/dart-core/Duration/inMilliseconds.html) | `${Duration(30000).inMilliseconds}` |
| [inMinutes](https://api.flutter.dev/flutter/dart-core/Duration/inMinutes.html) | `${Duration(30000).inMinutes}` |
| [inSeconds](https://api.flutter.dev/flutter/dart-core/Duration/inSeconds.html) | `${Duration(30000).inSeconds}` |
| `subtract(Duration duration)` | `${Duration({minutes: 5}).subtract(seconds(5))}` |
| `subtract(int milliseconds)` | `${Duration({minutes: 5}).subtract(5000)}` |

---

### Iterable

Several member functions from the [Iterable](https://api.flutter.dev/flutter/dart-core/Iterable-class.html) class are supported.

#### Member Functions

| Function | Example |
|----------|---------|
| [contains](https://api.flutter.dev/flutter/dart-core/Iterable/contains.html) | `${value.contains('string')}` |
| [elementAt](https://api.flutter.dev/flutter/dart-core/Iterable/elementAt.html) | `${value.elementAt(1)}` |
| [first](https://api.flutter.dev/flutter/dart-core/Iterable/first.html) | `${value.first}` |
| [isEmpty](https://api.flutter.dev/flutter/dart-core/Iterable/isEmpty.html) | `${value.isEmpty ? 'null' : value.first}` |
| [isNotEmpty](https://api.flutter.dev/flutter/dart-core/Iterable/isNotEmpty.html) | `${value.isNotEmpty ? value.first : 'null'}` |
| [last](https://api.flutter.dev/flutter/dart-core/Iterable/last.html) | `${value.last}` |
| [length](https://api.flutter.dev/flutter/dart-core/Iterable/length.html) | `${value.length}` |
| [join](https://api.flutter.dev/flutter/dart-core/Iterable/join.html) | `${value.join(',')}` |
| [single](https://api.flutter.dev/flutter/dart-core/Iterable/single.html) | `${value.single}` |
| [skip](https://api.flutter.dev/flutter/dart-core/Iterable/skip.html) | `${value.skip(1).join(',')}` |
| [take](https://api.flutter.dev/flutter/dart-core/Iterable/take.html) | `${value.take(3).join(',')}` |
| [toList](https://api.flutter.dev/flutter/dart-core/Iterable/toList.html) | `${value.toList().sort()}` |
| [toSet](https://api.flutter.dev/flutter/dart-core/Iterable/toSet.html) | `${value.toSet().first}` |


#### List

In addition to the items supported by the [Iterable](#iterable) class, a [List](https://api.flutter.dev/flutter/dart-core/List-class.html) additionally supports the following functions...


#### Member Functions

| Function | Example |
|----------|---------|
| [asMap](https://api.flutter.dev/flutter/dart-core/List/asMap.html) | `${list.asMap()[2]}` |
| [reversed](https://api.flutter.dev/flutter/dart-core/List/reversed.html) | `${list.reversed.first}` |
| [sort](https://api.flutter.dev/flutter/dart-core/List/sort.html) | `${list.sort().first}` |

---


### JsonPath

The [JsonPath](https://pub.dev/documentation/json_path/latest/json_path/JsonPath-class.html) class is supported to allow for walking JSON-like values.

#### Constructors

```
JsonPath(String expression)
```


#### Global Functions

| Function | Description | Example |
|----------|-------------|---------|
| `json_path(dynamic value, String path)` | Alias for `JsonPath(path).read(value).first.value` | `${json_path(object, '$.person.firstName')}` |


#### Member Functions

| Function | Example |
|----------|---------|
| [read](https://pub.dev/documentation/json_path/latest/json_path/JsonPath/read.html) | `${JsonPath('$.person.firstName').read(obj).first.value}` |
| [readValues](https://pub.dev/documentation/json_path/latest/json_path/JsonPath/readValues.html) | `${JsonPath('$.person.firstName').values(obj).first}` |

---

### JsonPathMatch

The [JsonPathMatch](https://pub.dev/documentation/json_path/latest/json_path/JsonPathMatch-class.html) class is supported to allow for walking JSON-like values.  It is unlikely you will want to create this class yourself and it is expected it will come from using [JsonPath](#jsonpath).


#### Member Functions

| Function | Example |
|----------|---------|
| [parent](https://pub.dev/documentation/json_path/latest/json_path/JsonPathMatch/parent.html) | `${JsonPath('$.person.firstName').read(obj).first.parent.value}` |
| [path](https://pub.dev/documentation/json_path/latest/json_path/JsonPathMatch/path.html) | `${JsonPath('$.person.firstName').read(obj).first.path}` |
| [value](https://pub.dev/documentation/json_path/latest/json_path/JsonPathMatch/value.html) | `${JsonPath('$.person.firstName').read(obj).first.value}` |

---

### Map

The following [Map](https://api.flutter.dev/flutter/dart-core/Map-class.html) members are supported.

#### Member Functions

| Function | Example |
|----------|---------|
| [containsValue](https://api.flutter.dev/flutter/dart-core/Map/containsValue.html) | `${map.containsValue('value')}` |
| [keys](https://api.flutter.dev/flutter/dart-core/Map/keys.html) | `${map.keys.first}` |
| [isEmpty](https://api.flutter.dev/flutter/dart-core/Map/isEmpty.html) | `${map.isEmpty ? 'null' : map.values.first}` |
| [isNotEmpty](https://api.flutter.dev/flutter/dart-core/Map/isNotEmpty.html) | `${map.isNotEmpty ? map.values.first : 'null'}` |
| [length](https://api.flutter.dev/flutter/dart-core/Map/length.html) | `${map.length}` |
| [remove](https://api.flutter.dev/flutter/dart-core/Map/remove.html) | `${map.remove('key')}` |
| [values](https://api.flutter.dev/flutter/dart-core/Map/values.html) | `${map.values.first}` |


---

### num

The following [num](https://api.flutter.dev/flutter/dart-core/num-class.html) members are supported.

#### Member Functions

| Function | Example |
|----------|---------|
| [abs](https://api.flutter.dev/flutter/dart-core/num/abs.html) | `${number.abs()}` |
| [ceil](https://api.flutter.dev/flutter/dart-core/num/ceil.html) | `${number.ceil()}` |
| [ceilToDouble](https://api.flutter.dev/flutter/dart-core/num/ceiltoDouble.html) | `${number.ceilToDouble()}` |
| [clamp](https://api.flutter.dev/flutter/dart-core/num/clamp.html) | `${number.clamp(lower, upper)}` |
| [compareTo](https://api.flutter.dev/flutter/dart-core/num/compareTo.html) | `${number.compareTo(other)}` |
| [floor](https://api.flutter.dev/flutter/dart-core/num/floor.html) | `${number.floor()}` |
| [floorToDouble](https://api.flutter.dev/flutter/dart-core/num/floorToDouble.html) | `${number.floorToDouble()}` |
| [isFinite](https://api.flutter.dev/flutter/dart-core/num/isFinite.html) | `${number.isFinite}` |
| [isInfinte](https://api.flutter.dev/flutter/dart-core/num/isInfinite.html) | `${number.isInfinte}` |
| [isNaN](https://api.flutter.dev/flutter/dart-core/num/isNaN.html) | `${number.isNaN}` |
| [isNegative](https://api.flutter.dev/flutter/dart-core/num/isNegative.html) | `${number.isNegative}` |
| [remainder](https://api.flutter.dev/flutter/dart-core/num/remainder.html) | `${number.remainder(other)}` |
| [round](https://api.flutter.dev/flutter/dart-core/num/round.html) | `${number.round()}` |
| [roundToDouble](https://api.flutter.dev/flutter/dart-core/num/roundToDouble.html) | `${number.roundToDouble}` |
| [sign](https://api.flutter.dev/flutter/dart-core/num/sign.html) | `${number.sign}` |
| [toDouble](https://api.flutter.dev/flutter/dart-core/num/toDouble.html) | `${number.toDouble()}` |
| [toInt](https://api.flutter.dev/flutter/dart-core/num/toInt.html) | `${number.toInt()}` |
| [toStringAsExponential](https://api.flutter.dev/flutter/dart-core/num/toStringAsExponential.html) | `${number.toStringAsExponential(fractionDigits)}` |
| [toStringAsFixed](https://api.flutter.dev/flutter/dart-core/num/toStringAsFixed.html) | `${number.toStringAsFixed(fractionDigits)}` |
| [toStringAsPrecision](https://api.flutter.dev/flutter/dart-core/num/toStringAsPrecision.html) | `${number.toStringAsPrecision(precision)}` |
| [truncate](https://api.flutter.dev/flutter/dart-core/num/truncate.html) | `${number.truncate()}` |
| [truncateToDouble](https://api.flutter.dev/flutter/dart-core/num/truncateToDouble.html) | `${number.truncateToDouble()}` |

---

### String

The following [String](https://api.flutter.dev/flutter/dart-core/String-class.html) members are supported.

#### Member Functions

| Function | Example |
|----------|---------|
| [compareTo](https://api.flutter.dev/flutter/dart-core/String/compareTo.html) | `${str.compareTo(other)}` |
| [contains](https://api.flutter.dev/flutter/dart-core/String/contains.html) | `${str.contains('other')}` |
| [endsWith](https://api.flutter.dev/flutter/dart-core/String/endsWith.html) | `${str.endsWith('other')}` |
| [indexOf](https://api.flutter.dev/flutter/dart-core/String/indexOf.html) | `${str.indexOf('other')}` |
| [isEmpty](https://api.flutter.dev/flutter/dart-core/String/isEmpty.html) | `${str.isEmpty ? 'null' : str}` |
| [isNotEmpty](https://api.flutter.dev/flutter/dart-core/String/isNotEmpty.html) | `${str.isNotEmpty ? str : 'null'}` |
| [lastIndexOf](https://api.flutter.dev/flutter/dart-core/String/lastIndexOf.html) | `${str.lastIndexOf('/')}` |
| [length](https://api.flutter.dev/flutter/dart-core/String/length.html) | `${str.length}` |
| [padLeft](https://api.flutter.dev/flutter/dart-core/String/padLeft.html) | `${str.padLeft(2, ' ')}` |
| [padRight](https://api.flutter.dev/flutter/dart-core/String/padRight.html) | `${str.padRight(2, ' ')}` |
| [replaceAll](https://api.flutter.dev/flutter/dart-core/String/replaceAll.html) | `${str.replaceAll('other', 'foo')}` |
| [replaceFirst](https://api.flutter.dev/flutter/dart-core/String/replaceFirst.html) | `${str.replaceFirst('other', 'foo')}` |
| [split](https://api.flutter.dev/flutter/dart-core/String/split.html) | `${str.split(',').join('\n')}` |
| [startsWith](https://api.flutter.dev/flutter/dart-core/String/startsWith.html) | `${str.startsWith('other')}` |
| [substring](https://api.flutter.dev/flutter/dart-core/String/substring.html) | `${str.substring(begin, end)}` |
| [toLowerCase](https://api.flutter.dev/flutter/dart-core/String/toLowerCase.html) | `${str.toLowerCase()}` |
| [toUpperCase](https://api.flutter.dev/flutter/dart-core/String/toUpperCase.html) | `${str.toUpperCase()}` |
| [trim](https://api.flutter.dev/flutter/dart-core/String/trim.html) | `${str.trim()}` |
| [trimLeft](https://api.flutter.dev/flutter/dart-core/String/trimLeft.html) | `${str.trimLeft()}` |
| [trimRight](https://api.flutter.dev/flutter/dart-core/String/trimRight.html) | `${str.trimRight()}` |


---

### Object

The following [Object](https://api.flutter.dev/flutter/dart-core/Object-class.html) members are supported.

#### Member Functions

| Function | Example |
|----------|---------|
| [hashCode](https://api.flutter.dev/flutter/dart-core/Object/hashCode.html) | `${obj.hashCode}` |
| [runtimeType](https://api.flutter.dev/flutter/dart-core/Object/runtimeType.html) | `${obj.runtimeType.toString()}` |
| [toString](https://api.flutter.dev/flutter/dart-core/Object/toString.html) | `${obj.toString()}` |
