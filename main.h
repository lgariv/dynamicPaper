#include <stdio.h>
#import "InternalSetWallpaper.h"
#import "EDSunriseSet.h"

const double kHour = 60*60;

@interface NSDateInterval (fix)
- (instancetype)initWithStartDate:(NSDate *)startDate 
                          endDate:(NSDate *)endDate;
@end

@interface NSTimer (fix)
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti 
                                     target:(id)aTarget 
                                   selector:(SEL)aSelector 
                                   userInfo:(id)userInfo 
                                    repeats:(BOOL)yesOrNo;@end

@interface PCSimpleTimer : NSObject {
	NSRunLoop* _timerRunLoop;
}
-(id)userInfo;
-(void)scheduleInRunLoop:(id)arg1 ;
-(id)initWithFireDate:(id)arg1 serviceIdentifier:(id)arg2 target:(id)arg3 selector:(SEL)arg4 userInfo:(id)arg5 ;
-(void)invalidate;
-(BOOL)disableSystemWaking;
-(void)setDisableSystemWaking:(BOOL)arg1 ;
-(BOOL)isUserVisible;
-(void)setUserVisible:(BOOL)arg1 ;
@end

@interface DynamicPaperManager : NSObject
@property (nonatomic, readwrite, strong) NSDate *nextSunrise;
@property (nonatomic, readwrite, strong) NSDate *nextSunset;
@property (nonatomic, readwrite, strong) NSArray *eightPics;
@property (nonatomic, readwrite, strong) UIImage *defaultLightWallpaper;
@property (nonatomic, readwrite, strong) UIImage *defaultDarkWallpaper;
- (id)initWithDict:(NSDictionary*)dict ;
- (void)setWallpaperForCurrentTime ;
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize ;
@end
