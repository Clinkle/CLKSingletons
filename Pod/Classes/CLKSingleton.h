#import "CLKSingletonManager.h"

#ifndef Clinkle_Singleton_h
#define Clinkle_Singleton_h

#define DECLARE_SINGLETON_FOR_CLASS(classname)\
DECLARE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(classname, singleton)

#define DECLARE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(classname, accessorMethodName)\
+ (classname *)accessorMethodName;\
+ (void)setup;\
+ (void)destroy;\
+ (BOOL)hasBeenCreated;


#define SYNTHESIZE_SINGLETON_FOR_CLASS(classname)\
SYNTHESIZE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(classname, singleton)

#define SYNTHESIZE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(classname, accessorMethodName)\
static classname *classname##accessorMethodName = nil;\
\
+ (classname *)accessorMethodName\
{\
    if (!classname##accessorMethodName) {\
        @synchronized(self) {\
            classname##accessorMethodName = [super allocWithZone:NULL];\
            classname##accessorMethodName = [classname##accessorMethodName init];\
            [CLKSingletonManager addSingleton:classname##accessorMethodName];\
        }\
    }\
    return classname##accessorMethodName;\
}\
\
+ (void)setup\
{\
    [self accessorMethodName];\
}\
\
+ (void)destroy\
{\
    [CLKSingletonManager removeSingleton:classname##accessorMethodName];\
    classname##accessorMethodName = nil;\
}\
\
+ (BOOL)hasBeenCreated\
{\
    return classname##accessorMethodName != nil;\
}

#endif
