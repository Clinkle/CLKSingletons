# CLKSingletons

CLKSingletons provides an elegant macro for declaring singletons in your iOS app.

It also provide tools to manage all of your singleton instances collectively, including KVOing on their properties and destroying them individually or all together.

For example:

```objc
@interface ContactBook : NSObject
DECLARE_SINGLETON_FOR_CLASS(ContactBook)
@end
```
```objc
@implementation ContactBook
SYNTHESIZE_SINGLETON_FOR_CLASS(ContactBook)
@end
```

Now `ContactBook` can be instantiated at most once.  Reference it as `[ContactBook singleton]` (or pass your own accessor, e.g. `sharedInstance`, as a second argument to the macros).  You can also call `[ContactBook destroy]` to kill the current instance or `[ContactBook hasBeenCreated]` to see whether it exists yet.

## Installation

Add `pod 'CLKSingletons'` to your `Podfile` or download the source [here](https://github.com/Clinkle/CLKSingletons)
