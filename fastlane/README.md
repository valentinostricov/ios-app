fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios increment
```
fastlane ios increment
```
Increment build and version
### ios test
```
fastlane ios test
```
Runs all the tests
### ios certificates
```
fastlane ios certificates
```
Load certificates
### ios dev
```
fastlane ios dev
```
Upload app to firebase

Add description:"Some description" to configure crashlytics version description
### ios dev_last
```
fastlane ios dev_last
```
Upload app to firebase

Add description:"Some description" to configure crashlytics version description

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
