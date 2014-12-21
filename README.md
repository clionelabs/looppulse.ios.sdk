# LoopPulse SDK

# Install the SDK

1. Download the LoopPulse and [Firebase](https://www.firebase.com/docs/) SDK

	Make sure you are using latest version of Xcode (5.1+) and targeting iOS 7.0 or higher.

2. Add the SDKs to your app

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

# Some notes on monitoring

1. Situation/Challenges
    - There is a limit of 20 monitoring regions allowed in iOS, and we might need to handle more than that

2. Current Approach
    1. We will only monitor generic region using UUID mask. e.g. if multiple beacons are sharing the same UUID, but different major/minor, we will only monitor a single generic region using the UUID mask.

    2. When didEnterRegion event is triggered on generic region, we then do a Ranging within that region, and locate the specific beacon's area we are in (We now know that we've entered that specific region). At the same time, we start monitor the specific beacon's region for didExitRegion event, after which we will unmonitor the specific region (and also know that we've exited that specific region).

    3. With this, we will be able to keep the number of required monitoring regions to a minimum, while at the same time still able to detect the entering/exiting event of specific beacons.

3. Limitations and Future Improvement
    1. The current limitation is that overlapping beacons shouldn't contain the same UUID, because we will be able to detect only the beacons during the ranging period upon entering the generic region.

    2. We can improve this by grouping nearby (overlapping) beacons, and monitor all of them upon entering a generic region, and unmonitor all of them upon leaving. This would be a future work, and we have to consider how are "nearby" being determined in this case, e.g. Should we read from server settings?
