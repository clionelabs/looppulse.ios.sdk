# LoopPulse SDK

# Install the SDK

1. Download the LoopPulse SDK

	Make sure you are using latest version of Xcode (5.1+) and targeting iOS 7.0 or higher.

2. Add the SDK to your app

	Drag the LoopPulse.framework and Firebase.framework folders you downloaded into your Xcode project folder target.
	
3. Add the dependencies

	Click on Targets -> Your app name -> and then the 'Build Phases' tab.
	Expand 'Link binary With Libraries' and add the following libraries:
	
	- libicucore.dylib
	- libc++.dylib
	- CFNetwork.framework
	- Security.framework
	- SystemConfiguration.framework
	- CoreBluetooth.framework