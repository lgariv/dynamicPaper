// #include "../main.h"

@import Foundation;
@interface NSTask : NSObject
-(id)launchPath;
-(void)setLaunchPath:(id)arg1 ;
-(void)launch;
@end

%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)application {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSTask *task = [[NSTask alloc] init];
        task.launchPath = @"/usr/local/bin/dynamicPaper";
        [task launch];
    });

    %orig;
}
%end
