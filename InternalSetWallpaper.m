#import "InternalSetWallpaper.h"

#include <dlfcn.h>

static NSString *frameworkPath(NSString *framework) {
        NSString *path;
    #if TARGET_OS_SIMULATOR
        path = @"/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/System/Library/PrivateFrameworks";
    #else
        path = @"/System/Library/PrivateFrameworks";
    #endif
        return [path stringByAppendingPathComponent:framework];
}

static void loadPrivateFramework(NSString *framework) {
    NSBundle *bundle = [NSBundle bundleWithPath:frameworkPath(framework)];
    [bundle load];
}

static void *loadFrameworkLibrary(NSString *framework) {
    NSString *libraryPath = [frameworkPath(framework) stringByAppendingPathComponent:[framework stringByDeletingPathExtension]];
    
    return dlopen(libraryPath.UTF8String, RTLD_LAZY);
}

void callIntegerSetMethodOnTarget(SEL selector, id target, NSInteger arg2) {
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:selector]];
    [inv setSelector:selector];
    [inv setTarget:target];
    [inv setArgument:&arg2 atIndex:2];
    [inv invoke];
}

@interface SBFWallpaperConfigurationManager
+(id)alloc;
-(id)init;
-(BOOL)setWallpaperImage:(id)arg1 wallpaperOptions:(id)arg2 forVariants:(long long)arg3;
- (void)wallpaperWillChangeForVariants:(long long)arg1;
- (void)notifyDelegateOfChangesToVariants:(long long)arg1;
- (void)beginChangeBatch;
- (void)performMigrationWithFailureHandler:(id /* block */)arg1;
@end

void setLightAndDarkWallpaperImages(UIImage *lightImage, UIImage *darkImage, int locations) {
    loadPrivateFramework(@"SpringBoardFoundation.framework");

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    
    id SBFWallpaperOptions = NSClassFromString(@"SBFWallpaperOptions");
    SEL initSelector = @selector(init);

    id lightOptions = [[SBFWallpaperOptions alloc] performSelector:initSelector];
    callIntegerSetMethodOnTarget(@selector(setWallpaperMode:), lightOptions, 1);

    id darkOptions = [[SBFWallpaperOptions alloc] performSelector:initSelector];
    callIntegerSetMethodOnTarget(@selector(setWallpaperMode:), darkOptions, 2);
    
    void *sbsUILib = loadFrameworkLibrary(@"SpringBoardUIServices.framework");
    if (@available(iOS 14, *)) {
        int (*_SBSUIWallpaperSetImages)(id imageDict, id optionsDict, int locations, int interfaceStyle) = dlsym(sbsUILib, "SBSUIWallpaperSetImages");
        _SBSUIWallpaperSetImages(@{@"light": lightImage, @"dark": darkImage},
                                @{@"light": lightOptions, @"dark": darkOptions},
                                locations,
                                UIUserInterfaceStyleDark);
    } else {
        SBFWallpaperConfigurationManager *wallpaperManager = [[objc_getClass("SBFWallpaperConfigurationManager") alloc] performSelector:initSelector];
        [wallpaperManager setWallpaperImage:lightImage wallpaperOptions:lightOptions forVariants:locations-1];
        [wallpaperManager setWallpaperImage:darkImage wallpaperOptions:darkOptions forVariants:locations-1];
        [wallpaperManager notifyDelegateOfChangesToVariants:locations];
        [wallpaperManager wallpaperWillChangeForVariants:locations];
        [wallpaperManager performMigrationWithFailureHandler:nil];
        [wallpaperManager beginChangeBatch];
    }

#pragma clang diagnostic pop
}