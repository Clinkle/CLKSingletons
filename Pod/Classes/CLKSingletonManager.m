#import "CLKSingletonManager.h"
#import "CLKKVO.h"

@interface CLKSingletonManager ()

@property (nonatomic, strong) NSMutableArray *singletons;
@property (nonatomic, strong) NSMutableArray *singletonKVOs;
@property (nonatomic, strong) NSMutableArray *singletonKVOsFromSingletons;

@end

@implementation CLKSingletonManager

#pragma mark - Singleton stuffs

static CLKSingletonManager *singletonManagerInstance = nil;

+ (CLKSingletonManager *)singleton
{
    if (!singletonManagerInstance) {
        @synchronized (self) {
            singletonManagerInstance = [super allocWithZone:NULL];
            singletonManagerInstance = [singletonManagerInstance init];
            [CLKSingletonManager addSingleton:singletonManagerInstance];
        }
    }
    return singletonManagerInstance;
}

+ (void)setup
{
    [self singleton]; // forces initialization
}

+ (void)destroy
{
    singletonManagerInstance = nil;
}

#pragma mark - lifecycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.singletons = [NSMutableArray array];
        self.singletonKVOs = [NSMutableArray array];
        self.singletonKVOsFromSingletons = [NSMutableArray array];
    }
    return self;
}

#pragma mark - singleton management

+ (NSArray *)destructionWhitelist
{
    // subclasses can whitelist classes here
    return @[];
}

+ (void)destroyAllSingletonsAndRestartKVOs:(BOOL)restartKVOs
{
    if (restartKVOs) {
        [self singletonsWillBeDestroyed];
    }

    [self destroySingletonsKVOingOtherSingletons];
    [self destroyRemainingSingletons];

    // TODO: this loses a reference to everything in the whitelist :(
    //    [self singleton].singletons = [NSMutableArray array];

    if (restartKVOs) {
        [self singletonsWereDestroyed];
    }
}

+ (void)destroySingletonsKVOingOtherSingletons
{
    NSMutableSet *singletonsKVOingOtherSingletons = [[NSMutableSet alloc] initWithCapacity:[self singleton].singletonKVOsFromSingletons.count];
    for (CLKKVO *kvo in [self singleton].singletonKVOsFromSingletons) {
        NSObject *singleton = kvo.observer;
        if (!singleton) {
            continue;
        }
        [singletonsKVOingOtherSingletons addObject:singleton];
        if (![[self destructionWhitelist] containsObject:[singleton class]]) {
            [kvo stopObserving];
            [[self singleton].singletonKVOs removeObject:kvo];
        }
    }
    for (NSObject *singleton in singletonsKVOingOtherSingletons) {
        if (![[self destructionWhitelist] containsObject:[singleton class]]) {
            [[singleton class] destroy];
        }
    }
}

+ (void)destroyRemainingSingletons
{
    NSSet *whitelist = [NSSet setWithArray:[self destructionWhitelist]];
    while (true) {
        NSArray *singletons = [[self singleton].singletons copy];
        BOOL shouldBreak = YES;
        for (NSObject *singleton in singletons) {
            if (![whitelist containsObject:[singleton class]]) {
                [[singleton class] destroy];
                shouldBreak = NO;
            }
        }
        if (shouldBreak) {
            break;
        }
    }
}

+ (void)addSingleton:(NSObject *)singleton
{
    if (singleton) {
        [[self singleton].singletons addObject:singleton];
    }
}

+ (void)removeSingleton:(NSObject *)singleton
{
    [[self singleton].singletons removeObject:singleton];
}

#pragma mark - kvo management
+ (void)addObserver:(id)observer
        toSingleton:(id)singleton
         forKeyPath:(NSString *)keyPath
{
    [self addObserver:observer
          toSingleton:singleton
           forKeyPath:keyPath
          withOptions:0];
}

+ (void)addObserver:(id)observer
        toSingleton:(id)singleton
         forKeyPath:(NSString *)keyPath
        withOptions:(NSKeyValueObservingOptions)options
{
    CLKKVO *kvo = [CLKKVO kvoWithObserver:observer
                        andSingletonClass:[singleton class]
                               forKeyPath:keyPath
                              withOptions:options];
    [[self singleton].singletonKVOs addObject:kvo];
    if ([[observer class] respondsToSelector:@selector(singleton)]) {
        [[self singleton].singletonKVOsFromSingletons addObject:kvo];
    }
    [kvo startObserving];
}

+ (void)removeObserver:(id)observer
    fromSingletonClass:(Class)singletonClass
            forKeyPath:(NSString *)keyPath
{
    CLKKVO *extantKVO = nil;
    for (CLKKVO *kvo in [self singleton].singletonKVOs) {
        if ([kvo.keyPath isEqualToString:keyPath] &&
            kvo.singletonClass == singletonClass &&
            (kvo.observer == observer || kvo.observer == nil))
        {
            extantKVO = kvo;
            if (extantKVO.observer == nil) {
                // means observer is being dealloc'd and it's been nil'd from the weak reference
                extantKVO.strongObserver = observer;
            }
            break;
        }
    }

    if (extantKVO != nil) {
        [extantKVO stopObserving];
        [[self singleton].singletonKVOs removeObject:extantKVO];
        [[self singleton].singletonKVOsFromSingletons removeObject:extantKVO];
        extantKVO.strongObserver = nil;
    }
}

+ (void)singletonsWereDestroyed
{
    for (CLKKVO *kvo in [self singleton].singletonKVOs) {
        [kvo startObserving];
    }
}

+ (void)singletonsWillBeDestroyed
{
    NSArray *whitelist = [self destructionWhitelist];
    NSMutableSet *kvosToRemove = [NSMutableSet setWithCapacity:[self singleton].singletonKVOs.count];
    for (CLKKVO *kvo in [self singleton].singletonKVOs) {
        [kvo stopObserving];
        // don't let things that are about to be destroyed try to stop observing again
        if ([[self singleton].singletons containsObject:kvo.observer] && ![whitelist containsObject:[kvo.observer class]]) {
            [kvosToRemove addObject:kvo];
        }
    }
    for (CLKKVO *kvo in kvosToRemove) {
        [[self singleton].singletonKVOs removeObject:kvo];
        [[self singleton].singletonKVOsFromSingletons removeObject:kvo];
    }
}

@end
