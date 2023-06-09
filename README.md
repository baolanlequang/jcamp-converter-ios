# JcampConverter
**JcampConverter** is a open-source package to convert JCAMP-DX files to spectra.

## How to user JcampConverter
**JcampConverter** is released as dependency package on [CocoaPods](https://cocoapods.org/). 

### 1. Add *MoJcampConverter* to your project
1.1. Setting up *cocoapods*

You can by pass this step if your project is using *cocoapods*.

Open your terminal, navigate to the project's location and type

```
pod init
```

1.2. Add *JcampConverter*


Open `Podfile` and add

```
pod 'JcampConverter', '~> 0.1.0'
```
 
Open your terminal, navigate to the project's location and the following commad to install *MoJcampConverter* to your project.

```
pod install
```

### 2. Using *JcampConverter*
Open your `<Project_Name>.xcworkspace`

2.1. Import *JcampConverter*

```swift
import JcampConverter
```

2.2. Using the converter
```swift
let reader = JcampReader(filePath: path)

//example read number of x of spectrum
for spec in reader.jcamp!.spectra {
    print(spec.xValues.count)
}
```
            
            

