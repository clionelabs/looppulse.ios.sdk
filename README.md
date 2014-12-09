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

# Region Monitoring Logic

1. Situation/Challenges
    1. There is a limit of 20 monitoring regions allowed in iOS

    2. We might need to monitor more than 20 beacons, in which their covered areas might overlap

2. Approach
    1. We introduced a concept of "Generic Region"
        - A Beacon contains i) UUID, ii) major, and iii) minor
        - A Generic Region contains only i) UUID, and ii) major
        - So, a Generic Region wrap over multiple number of beacons which contain the same UUID and major

    2. The "Generic Region" is counter-intuitive in the following sense:
        - In usual thinkings, a "generic" region is location-bound, meaning that all beacons under the same region should be located without certain physical boundary, and generic reagion A and generic region B would mean two mutually exclusive physical boundaries. It would be a logical groupings of beacons, since a pair of UUID and major would provide insights on the physical locations of beacons.
        - In our unusual settings, the "Generic Region" has `NO` such meaning. Beacons within the same region do not mean they sit inside the same physical boundary. On the contrary, we enforced a special rule that beacons having the same UUID and major `CANNOT` contain overlapping area.

    3. The reason for enforcing this special rule is to ease the monitoring logic in order to tackle the problem mentioned in the above section.
        - With the above rule enforced, it means that we can simply monitor all UUID-major pairs, instead of each beacons individually. Note: You can choose to monitor `UUID`, `UUID + major`, or `UUID + major + minor` in IOS.
        - So our approach is to monitor these "Generic Region". When didEnterRegion event is triggered, we then do a Ranging within that region, and locate which specific beacon's area we are in. We will at the same time monitor that specific beacon's region for the didExitRegion event, after which we will unmonitor the specific region. By this, we will be able to capture the entering and exiting time of each individual beacon.
        - With this approach, the number of monitoring regions required is the number of "Generic Regions" plus the number of individual beacons' area we could get into at a particular time. Given the fact that in real situation, the number of beacons having overlapped area shouldn't be a lot, meaning that we only need a small number of UUID-major pairs.

3. Limitations
    1. Although the number of monitored regions are greatly reduced, there are still limits on the number of "Generic Regions".
        - Ideally, the number of "Generic Regions" shouldn't exceed 10, because we still need to reserve spots for individual beacons once the user enter the "Generic Regions"
    2. This would require extra effort in setting up the beacons so their UUID-major-minor values follow the rule - `No two overlappnig beacons should share the same pair of UUID-major`
