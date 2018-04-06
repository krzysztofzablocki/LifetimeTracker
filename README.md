# LifetimeTracker

 
| ![Demo (bar)](Resources/demo-bar.gif) | | ![Demo (circular)](Resources/demo-circular.gif) |
|:--:| :--: | :--: |
| Bar style | | Circular style |

LifetimeTracker can surface retain cycle / memory issues right as you develop your application, and it will surface them to you immediately, so you can find them with more ease.

Instruments and Memory Graph Debugger are great, but too many times developers forget to check for issues as they close the feature implementation.

If you use those tools sporadicaly many of the issues they surface will require you to investigate the cause, and cost you a lot of time in the process.

Other tools like [FBRetainCycleDetector](https://github.com/facebook/FBRetainCycleDetector) rely on objc runtime magic to find the problems, but that means they can't really be used for pure Swift classes. This small tool simply focuses on tracking lifetime of objects which means that it can be used in both Objective-C and Swift codebases and it doesn't rely on any complex or automatic magic behaviour.

## Installation

### CocoaPods

Add `pod 'LifetimeTracker'` to your Podfile.

### Carthage

Add `github "krzysztofzablocki/LifetimeTracker"` to your Cartfile.

## Integration

To Integrate visual notifications simply add following line at the start of `AppDelegate(didFinishLaunchingWithOptions:)`.

Swift:

```swift
#if DEBUG
	LifetimeTracker.setup(onUpdate: LifetimeTrackerDashboardIntegration(visibility: .alwaysVisible, style: .bar).refreshUI)
#endif
```

Objective-C:

```objc
LifetimeTrackerDashboardIntegration *dashboardIntegration = [LifetimeTrackerDashboardIntegration new];
[dashboardIntegration setVisibleWhenIssueDetected];
[dashboardIntegration useBarStyle];
[LifetimeTracker setupOnUpdate:^(NSDictionary<NSString *,EntriesGroup *> * groups) {
    [dashboardIntegration refreshUIWithTrackedGroups: groups];
}];
```

You can control when the dashboard is visible: `alwaysVisible`, `alwaysHidden`, or `visibleWithIssuesDetected`.

There are two styles available. A overlay bar view which shows the detailed list of issues directly on the screen or a circular view which displays only the amount of issues and opens the detailed list as modal view controller.

## Tracking key actors

Usually you want to use LifetimeTracker to track only key actors in your app, like ViewModels / Controllers etc. When you have more than `maxCount` items alive, the tracker will let you know.

### Swift

You conform to `LifetimeTrackable` and call `trackLifetime()` at the end of your init functions:

```swift
class SectionFrontViewController: UIViewController, LifetimeTrackable {
    static var lifetimeConfiguration = LifetimeConfiguration(maxCount: 1, groupName: "VC")

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        /// ...
        trackLifetime()
    }
}
```

### Objective-C

You conform to `LifetimeTrackable` and call `[self trackLifetime]` at the end of your init functions:

```objc
@import LifetimeTracker;

@interface SectionFrontViewController() <LifetimeTrackable>

@implementation SectionFrontViewController

+(LifetimeConfiguration *)lifetimeConfiguration
{
    return [[LifetimeConfiguration alloc] initWithMaxCount:1 groupName:@"VC"];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    	/// …
        [self trackLifetime];
    }
    return self;
}
@end
```


## Group tracked objects

You can group tracked objects together. `maxCount` of a group will be calculated by `maxCount` of all members per default. However, you can override it and provide a separate value to the group with `groupMaxCount`.

You may want to do this when you have a set of sublasses which can appear x times each, but in total only less than the sum of all sublcasses:

```swift
// DetailPage: UIViewController

// VideoDetailPage: DetailItem
LifetimeConfiguration(maxCount: 3, groupName: "Detail Page")

// ImageDetailPage: DetailItem
LifetimeConfiguration(maxCount: 3, groupName: "Detail Page")

=> Group warning if 7 DetailPage objects are alive

// VideoDetailPage: DetailItem
LifetimeConfiguration(maxCount: 3, groupName: "Detail Page", groupMaxCount: 3)

// ImageDetailPage: DetailItem
LifetimeConfiguration(maxCount: 3, groupName: "Detail Page", groupMaxCount: 3)

=> Group warning if 4 DetailPage object are alive

```

## Writing integration tests for memory leaks

You can access the summary label using accessibility identifier `LifetimeTracker.summaryLabel`, which allows you to write integration tests that end up with looking up whether any issues were found.

## License 
LifetimeTracker is available under the MIT license. See [LICENSE](LICENSE) for more information.

## Attributions

I've used [SwiftPlate](https://github.com/JohnSundell/SwiftPlate) to generate xcodeproj compatible with CocoaPods and Carthage.
