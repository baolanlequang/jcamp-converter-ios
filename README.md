# JcampConverter
**JcampConverter** is a open-source package to convert JCAMP-DX files to spectra.

![GitHub release (release name instead of tag name)](https://img.shields.io/github/v/release/baolanlequang/jcamp-converter-ios?include_prereleases&label=version)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.8022920.svg)](https://doi.org/10.5281/zenodo.8022920)

## Citation
If you use this libary, it will be great if you can cite this on your works

```citation
Lan Le. (2023). jcamp-converter-ios (0.1.1). Zenodo. https://doi.org/10.5281/zenodo.8022920
```


If you like my works, you can <a href="https://www.buymeacoffee.com/baolanlequang" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 30px !important;width: 117px !important;" ></a>

## How to use JcampConverter
**JcampConverter** is released as dependency package on [CocoaPods](https://cocoapods.org/). 

### 1. Add *JcampConverter* to your project
1.1. Setting up *cocoapods*

You can by pass this step if your project is using *cocoapods*.

Open your terminal, navigate to the project's location and type

```
pod init
```

1.2. Add *JcampConverter*


Open `Podfile` and add

```
pod 'JcampConverter', '~> 0.1.1'
```

or
```
pod` 'JcampConverter', :git => 'https://github.com/baolanlequang/jcamp-converter-ios'
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
let jcampData = "<url string or content of your jcamp file>"
let jcamp = Jcamp(jcampData)

```

### 3. Demo
You can clone project [jcamp-viewer-ios](https://github.com/baolanlequang/jcamp-viewer-ios) to see how it works.
            
            

