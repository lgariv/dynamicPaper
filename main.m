#include <stdio.h>
#import "InternalSetWallpaper.h"
#import "EDSunriseSet.h"

const double kHour = 60*60;

// int main(int argc, char *argv[], char *envp[]) {
// 	@autoreleasepool {
// 		printf("Hello world!\n");
//         NSString *lightPath = [[NSString alloc] initWithCString:argv[0] encoding:NSUTF8StringEncoding];
//         NSString *darkPath = [[NSString alloc] initWithCString:argv[1] encoding:NSUTF8StringEncoding];
// 		UIImage *light = [UIImage imageWithContentsOfFile:lightPath];
// 		UIImage *dark = [UIImage imageWithContentsOfFile:darkPath];
// 		setLightAndDarkWallpaperImages(light, dark, 3);
// 		return 0;
// 	}
// }

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
@end

int main(int argc, char *argv[], char *envp[]) {
	@autoreleasepool {
		// DynamicPaperManager *daemon = [DynamicPaperManager new];

		// printf("%s\n", [[NSString stringWithFormat:@"%@", [daemon nextSunrise]] UTF8String]);
		// printf("%s\n", [[NSString stringWithFormat:@"%@", [daemon nextSunset]] UTF8String]);
		// return 0;

        // NSString *folderPath = [[NSString alloc] initWithCString:argv[0] encoding:NSUTF8StringEncoding];
		NSString *folderPath = [NSHomeDirectory() stringByAppendingPathComponent:@"pics/pics"];
		NSArray *folderItems = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
		int numberOfFileInFolder = [folderItems count];

		// NSTimeInterval secondsBetween = [daemon.nextSunset timeIntervalSinceDate:daemon.nextSunrise];

		NSMutableDictionary *dict = [NSMutableDictionary new];
		for (int i=0; i<numberOfFileInFolder; i++) {
			UIImage *image = [UIImage imageWithContentsOfFile:[folderPath stringByAppendingPathComponent:folderItems[i]]];
			[dict setObject:image forKey:[NSString stringWithFormat:@"%d", i]];
		}
		DynamicPaperManager *daemon = [[DynamicPaperManager alloc] init];

		//start a timer so that the process does not exit.
		NSTimer *startTimer = [[NSTimer alloc] initWithFireDate:[NSDate date]
			interval:0.01
			target:daemon
			selector:@selector(initialTimer:)
			userInfo:dict
			repeats:NO];
		NSRunLoop *runLoop = [NSRunLoop mainRunLoop];
		[runLoop addTimer:startTimer forMode:NSDefaultRunLoopMode];
		[runLoop run];
	// UIImage __block* lightWallpaper = nil;
	// UIImage __block* darkWallpaper = nil;
	// 	NSString *defaultFolderPath = [NSHomeDirectory() stringByAppendingPathComponent:@"pics"];
	// 	NSArray *defaultFolderItems = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:defaultFolderPath error:nil];
	// 	for (NSString *item in defaultFolderItems) {
	// 		if ([item containsString:@"Dark"]) {
	// 			darkWallpaper = [UIImage imageWithContentsOfFile:[defaultFolderPath stringByAppendingPathComponent:item]];
	// 			break;
	// 		}
	// 	}
	// 	for (NSString *item in defaultFolderItems) {
	// 		if ([item containsString:@"Light"]) {
	// 			lightWallpaper = [UIImage imageWithContentsOfFile:[defaultFolderPath stringByAppendingPathComponent:item]];
	// 			break;
	// 		}
	// 	}
	// if (lightWallpaper == nil) printf("lightWallpaper is nil\n");
	// if (darkWallpaper == nil) printf("darkWallpaper is nil\n");
	// printf("none is nil1\n");
	// setLightAndDarkWallpaperImages(lightWallpaper, darkWallpaper, 3);
	// 	printf("none is nil2\n");
		return 0;
	}
}

@implementation DynamicPaperManager
- (id)init {
	printf("none is nil00\n");

	NSTimeZone* tz = [NSTimeZone localTimeZone];

    EDSunriseSet *sunriset = [[EDSunriseSet alloc] initWithDate:[NSDate date] timezone:tz latitude:30 longitude:30];

	NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:[NSDate date]];

	NSCalendar *cal = [NSCalendar currentCalendar];
	[sunriset.localSunrise setYear:components.year];
	[sunriset.localSunrise setMonth:components.month];
	[sunriset.localSunrise setDay:components.day];
	// [sunriset.localSunrise setDay:components.day+1];
	[sunriset.localSunset setYear:components.year];
	[sunriset.localSunset setMonth:components.month];
	[sunriset.localSunset setDay:components.day];
	// [sunriset.localSunset setDay:components.day+1];
	NSDate *sunrisetSunrise = [cal dateFromComponents:sunriset.localSunrise];
	NSDate *sunrisetSunset = [cal dateFromComponents:sunriset.localSunset];

	self.nextSunrise = sunrisetSunrise;
	self.nextSunset = sunrisetSunset;

	// NSTimeInterval secondsBetween = [self.nextSunset timeIntervalSinceDate:self.nextSunrise];

	// NSMutableArray *sunrise = [[NSMutableArray alloc] initWithObjects: [NSNumber numberWithDouble:(-1)*kHour], [NSNumber numberWithInt:0], [NSNumber numberWithDouble:kHour], [NSNumber numberWithDouble:4*kHour]];
	// NSMutableArray *sunset = [[NSMutableArray alloc] initWithObjects: [NSNumber numberWithDouble:(-0.5)*kHour], [NSNumber numberWithInt:0], [NSNumber numberWithDouble:1.5*kHour], [NSNumber numberWithDouble:3*kHour]] ;
	NSMutableArray *sunrise = [[NSMutableArray alloc] init];
	[sunrise addObject:[NSNumber numberWithDouble:(-1)*kHour]];
	[sunrise addObject:[NSNumber numberWithInt:0]];
	[sunrise addObject:[NSNumber numberWithDouble:kHour]];
	[sunrise addObject:[NSNumber numberWithDouble:4*kHour]];
	NSMutableArray *sunset = [[NSMutableArray alloc] init];
	[sunset addObject:[NSNumber numberWithDouble:(-0.5)*kHour]];
	[sunset addObject:[NSNumber numberWithInt:0]];
	[sunset addObject:[NSNumber numberWithDouble:1.5*kHour]];
	[sunset addObject:[NSNumber numberWithDouble:3*kHour]];
	NSMutableArray *eightPics = [[NSMutableArray alloc] init];
	[eightPics addObject:sunrise];
	[eightPics addObject:sunset];
	self.eightPics = eightPics;

	NSString *folderPath = [NSHomeDirectory() stringByAppendingPathComponent:@"pics"];
	NSArray *folderItems = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
	for (NSString *item in folderItems) {
		if ([item containsString:@"Light"]) {
			self.defaultLightWallpaper = [UIImage imageWithContentsOfFile:[folderPath stringByAppendingPathComponent:item]];
		}
		if ([item containsString:@"Dark"]) {
			self.defaultDarkWallpaper = [UIImage imageWithContentsOfFile:[folderPath stringByAppendingPathComponent:item]];
		}
	}

	return self;
}

- (void)initialTimer:(id)timer {
	printf("none is nil0\n");

    NSDictionary* userInfo = [[(NSTimer *)timer userInfo] copy];

    // NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

    // NSDateComponents *todayComponents = [gregorian components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:[NSDate date]];
    // NSInteger theDay = [todayComponents day];
    // NSInteger theMonth = [todayComponents month];
    // NSInteger theYear = [todayComponents year];

    // NSDateComponents *components = [[NSDateComponents alloc] init];
    // [components setDay:theDay]; 
    // [components setMonth:theMonth]; 
    // [components setYear:theYear];
    // [components setTimeZone:[NSTimeZone localTimeZone]];

    // NSDate* todayDate = [gregorian dateFromComponents:components];

	// NSDateInterval *timeUntilMidnight = [[NSDateInterval alloc] initWithStartDate:[NSDate date] endDate:todayDate];
	// NSRunLoop *runLoop = [NSRunLoop mainRunLoop];

	printf("crash101\n");

    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
		for (int i=0; i<4; i++) {
			NSDate *timeSinceSunrise = [NSDate dateWithTimeInterval:[[self eightPics][0][i] doubleValue] sinceDate:self.nextSunrise];
			printf("crash102: %s\n", [[NSString stringWithFormat:@"%@", timeSinceSunrise] UTF8String]);
			NSMutableDictionary *wallpaperData = [NSMutableDictionary new];
			UIImage *image = userInfo[[NSString stringWithFormat:@"%d", i]];
			[wallpaperData setObject:image forKey:[NSString stringWithFormat:@"sunrise%d", i]];
			PCSimpleTimer *wallpaperTimer = [[PCSimpleTimer alloc] initWithFireDate:timeSinceSunrise
								serviceIdentifier:@"com.miwix.dynamicpaper.service"
								target:self
								selector:@selector(changeWallpaper:)
								userInfo:wallpaperData];
			printf("crash106\n");
			// [wallpaperTimer setDisableSystemWaking:YES];
			printf("crash107\n");
			dispatch_async(dispatch_get_main_queue(), ^{
				NSRunLoop *runLoop = [NSRunLoop mainRunLoop];
				[runLoop addTimer:wallpaperTimer forMode:NSDefaultRunLoopMode];
				[runLoop run];
			});
			// [wallpaperTimer scheduleInRunLoop:[NSRunLoop mainRunLoop]];
		}
		for (int i=4; i<8; i++) {
			printf("crash102: %s\n", [[NSString stringWithFormat:@"%@", [self eightPics][1][i-4]] UTF8String]);
			NSDate *timeSinceSunset = [NSDate dateWithTimeInterval:[[self eightPics][1][i-4] doubleValue] sinceDate:self.nextSunset];
			NSMutableDictionary *wallpaperData = [NSMutableDictionary new];
			UIImage *image = userInfo[[NSString stringWithFormat:@"%d", i]];
			[wallpaperData setObject:image forKey:[NSString stringWithFormat:@"sunset%d", i]];
			PCSimpleTimer *wallpaperTimer = [[PCSimpleTimer alloc] initWithFireDate:timeSinceSunset
								serviceIdentifier:@"com.miwix.dynamicpaper.service"
								target:self
								selector:@selector(changeWallpaper:)
								userInfo:wallpaperData];
			// [wallpaperTimer setDisableSystemWaking:YES];
			printf("crash106\n");
			dispatch_async(dispatch_get_main_queue(), ^{
				NSRunLoop *runLoop = [NSRunLoop mainRunLoop];
				[runLoop addTimer:wallpaperTimer forMode:NSDefaultRunLoopMode];
				[runLoop run];
			});
			// [wallpaperTimer scheduleInRunLoop:[NSRunLoop mainRunLoop]];
			printf("crash107\n");
		}
		// dispatch_async(dispatch_get_main_queue(), ^{
			printf("invalidate0\n");
			[timer invalidate];
			printf("invalidate1\n");
			[self setWallpaperForCurrentTime];
			printf("setWallpaperForCurrentTime\n");
		// });
	});
}

- (void)changeWallpaper:(PCSimpleTimer *)timer {
	NSDictionary *userInfo = timer.userInfo;
	UIImage *lightWallpaper = userInfo.allValues[0];
	UIImage *darkWallpaper = userInfo.allValues[0];
	if ([userInfo.allKeys[0] containsString:@"sunset"]) {
		darkWallpaper = self.defaultDarkWallpaper;
	} else {
		lightWallpaper = self.defaultLightWallpaper;
	}
	dispatch_async(dispatch_get_main_queue(), ^{
		setLightAndDarkWallpaperImages(lightWallpaper, darkWallpaper, 3);
	});
}

- (void)setWallpaperForCurrentTime {
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
		printf("setWallpaperForCurrentTime1\n");
		NSMutableArray *sunriseTimes = [[NSMutableArray alloc] init];
		NSMutableArray *sunsetTimes = [[NSMutableArray alloc] init];
		for (NSNumber *relativeTime in [self eightPics][0]) {
			printf("relativeTime: %f\n", [relativeTime doubleValue]);
			NSDate *timestamp = [[NSDate alloc] initWithTimeInterval:[relativeTime doubleValue] sinceDate:self.nextSunrise];
			printf("timestamp: %s\n", [[NSString stringWithFormat:@"%@", timestamp] UTF8String]);
			[sunriseTimes addObject:timestamp];
		}
		for (NSNumber *relativeTime in [self eightPics][1]) {
			printf("relativeTime: %f\n", [relativeTime doubleValue]);
			NSDate *timestamp = [[NSDate alloc] initWithTimeInterval:[relativeTime doubleValue] sinceDate:self.nextSunset];
			printf("timestamp: %s\n", [[NSString stringWithFormat:@"%@", timestamp] UTF8String]);
			[sunsetTimes addObject:timestamp];
		}
		printf("setWallpaperForCurrentTime2\n");

		printf("sunriseTimes: %s\n", [[NSString stringWithFormat:@"%@", [sunriseTimes description]] UTF8String]);
		printf("sunsetTimes: %s\n", [[NSString stringWithFormat:@"%@", [sunsetTimes description]] UTF8String]);

		NSTimeInterval sunriseInterval = fabs([sunriseTimes[0] timeIntervalSinceDate:[NSDate date]]);
		NSUInteger indexOfSunriseDate = 0;
		// for (NSDate *date in sunriseTimes) {
		for (int i=1; i<[sunriseTimes count]; i++) {
			if (fabs([sunriseTimes[i] timeIntervalSinceDate:[NSDate date]]) < sunriseInterval) {
				sunriseInterval = fabs([sunriseTimes[i] timeIntervalSinceDate:[NSDate date]]);
		printf("sunriseInterval: %f\n", sunriseInterval);
				indexOfSunriseDate = i;
			}
		}

		NSTimeInterval sunsetInterval = fabs([sunsetTimes[0] timeIntervalSinceDate:[NSDate date]]);
		NSUInteger indexOfSunsetDate = 0;
		// for (NSDate *date in sunsetTimes) {
		for (int i=1; i<[sunsetTimes count]; i++) {
			if (fabs([sunsetTimes[i] timeIntervalSinceDate:[NSDate date]]) < sunsetInterval) {
				sunsetInterval = fabs([sunsetTimes[i] timeIntervalSinceDate:[NSDate date]]);
		printf("sunsetInterval: %f\n", sunsetInterval);
				indexOfSunsetDate = i;
			}
		}

		printf("indexOfSunriseDate: %d, sunriseInterval: %d\n", indexOfSunriseDate, sunriseInterval);
		printf("indexOfSunsetDate: %d, sunsetInterval: %d\n", indexOfSunsetDate, sunsetInterval);

		NSString *folderPath = [NSHomeDirectory() stringByAppendingPathComponent:@"pics/pics"];
		NSArray *folderItems = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
		NSUInteger finalIndex;
		if (sunsetInterval <= sunriseInterval) {
			finalIndex = indexOfSunriseDate;
			UIImage *wallpaper = [UIImage imageWithContentsOfFile:[folderPath stringByAppendingPathComponent:folderItems[finalIndex]]];
			printf("setWallpaperForCurrentTime41\n");
			// dispatch_sync(dispatch_get_main_queue(), ^{
				printf("setWallpaperForCurrentTime4\n");
				setLightAndDarkWallpaperImages(wallpaper, self.defaultDarkWallpaper, 3);
			// });
		} else {
			finalIndex = indexOfSunsetDate;
			UIImage *wallpaper = [UIImage imageWithContentsOfFile:[folderPath stringByAppendingPathComponent:folderItems[finalIndex+4]]];
			printf("setWallpaperForCurrentTime51\n");
			// dispatch_sync(dispatch_get_main_queue(), ^{
				printf("setWallpaperForCurrentTime5\n");
				setLightAndDarkWallpaperImages(self.defaultLightWallpaper, wallpaper, 3);
			// });
		}
		printf("setWallpaperForCurrentTime6\n");
	});
}
@end
