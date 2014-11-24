#import <Foundation/Foundation.h>
#import "CLKSingletons.h"

@interface CLKSingletonManager : NSObject

+ (void)addSingleton:(NSObject *)singleton;

+ (void)removeSingleton:(NSObject *)singleton;

+ (CLKSingletonManager *)singleton;

+ (void)setup;

+ (void)destroy;

+ (void)destroyAllSingletonsAndRestartKVOs:(BOOL)restartKVOs;

+ (void)addObserver:(id)observer
        toSingleton:(id)singleton
         forKeyPath:(NSString *)keyPath
        withOptions:(NSKeyValueObservingOptions)options;

+ (void)addObserver:(id)observer
        toSingleton:(id)singleton
         forKeyPath:(NSString *)keyPath;

+ (void)removeObserver:(id)observer
    fromSingletonClass:(Class)singletonClass
            forKeyPath:(NSString *)keyPath;

@end
