#import <Foundation/Foundation.h>

@interface CLKKVO : NSObject

+ (CLKKVO *)kvoWithObserver:(id)observer
          andSingletonClass:(Class)singletonClass
                 forKeyPath:(NSString *)keyPath
                withOptions:(NSKeyValueObservingOptions)options;

+ (CLKKVO *)kvoWithObserver:(id)observer
          andSingletonClass:(Class)singletonClass
                 forKeyPath:(NSString *)keyPath;

@property (nonatomic, weak) id observer;
@property (nonatomic, strong) id strongObserver;
@property (nonatomic, strong) Class singletonClass;
@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic, assign) NSKeyValueObservingOptions options;

- (void)startObserving;

- (void)stopObserving;

@end
