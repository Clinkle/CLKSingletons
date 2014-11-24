#import "CLKKVO.h"

@interface CLKKVO ()

@property (nonatomic, weak) id singletonInstance;
@end

@implementation CLKKVO

+ (CLKKVO *)kvoWithObserver:(id)observer
          andSingletonClass:(Class)singletonClass
                 forKeyPath:(NSString *)keyPath
                withOptions:(NSKeyValueObservingOptions)options
{
    CLKKVO *kvo = [[CLKKVO alloc] init];
    kvo.observer = observer;
    kvo.singletonClass = singletonClass;
    kvo.keyPath = keyPath;
    kvo.options = options;
    return kvo;
}

+ (CLKKVO *)kvoWithObserver:(id)observer
          andSingletonClass:(Class)singletonClass
                 forKeyPath:(NSString *)keyPath;
{
    CLKKVO *kvo = [CLKKVO kvoWithObserver:observer
                        andSingletonClass:singletonClass
                               forKeyPath:keyPath
                              withOptions:NSKeyValueObservingOptionNew];
    return kvo;
}

- (void)startObserving
{
    self.singletonInstance = self.currentInstance;
    [self.singletonInstance addObserver:self.observer
                             forKeyPath:self.keyPath
                                options:self.options
                                context:nil];
}

- (void)stopObserving
{
    if (![self singletonHasBeenCreated]) {
        return;
    }
    if (self.currentInstance != self.singletonInstance) {
        return;
    }
    id observer = self.observer ?: self.strongObserver;
    if (self.keyPath == nil || observer == nil) {
        return;
    }
    [self.currentInstance removeObserver:observer
                              forKeyPath:self.keyPath];
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[CLKKVO class]]) {
        return NO;
    }
    CLKKVO *other = (CLKKVO *)object;
    return ([other.keyPath isEqualToString:self.keyPath] && other.singletonClass == self.singletonClass && self.observer == other.observer);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ observing %@ at keypath %@ with options %@",
                                      self.observer,
                                      self.singletonClass,
                                      self.keyPath,
                                      @(self.options)];
}

#       pragma clang diagnostic push
#       pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (id)currentInstance
{
    return [self.singletonClass performSelector:sel_registerName("singleton")];
}

- (BOOL)singletonHasBeenCreated
{
    return (BOOL)[self.singletonClass performSelector:sel_registerName("hasBeenCreated")];
}
#       pragma clang diagnostic pop

@end
