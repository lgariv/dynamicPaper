#import "main.h"

#define kScreenHeight [[UIScreen mainScreen] bounds].size.height
#define kCurrentAppearanceIsLight [[[UIScreen mainScreen] traitCollection] userInterfaceStyle] == UIUserInterfaceStyleLight

int main(int argc, char *argv[], char *envp[]) {
	@autoreleasepool {
        // NSString *folderPath = [[NSString alloc] initWithCString:argv[0] encoding:NSUTF8StringEncoding];
		NSString *homeDirectory = [[NSHomeDirectory() stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"root"];
		NSString *folderPath = [homeDirectory stringByAppendingPathComponent:@"pics/pics"];
		NSArray *folderItems = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
		folderItems = [folderItems sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
		int numberOfFileInFolder = [folderItems count];

		NSMutableDictionary *dict = [NSMutableDictionary new];
		for (int i=0; i<numberOfFileInFolder; i++) {
			UIImage *image = [UIImage imageWithContentsOfFile:[folderPath stringByAppendingPathComponent:folderItems[i]]];
			[dict setObject:image forKey:[NSString stringWithFormat:@"%d", i]];
		}
		DynamicPaperManager *daemon = [[DynamicPaperManager alloc] init];

		//start a timer so that the process does not exit.
		if ([NSHomeDirectory() containsString:@"root"]) {
			NSTimer *startTimer = [[NSTimer alloc] initWithFireDate:[NSDate date]
				interval:0.01
				target:daemon
				selector:@selector(initialTimer:)
				userInfo:dict
				repeats:NO];
			NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
			[runLoop addTimer:startTimer forMode:NSRunLoopCommonModes];
			[runLoop run];
		}
		[daemon setWallpaperForCurrentTime];
		return 0;
	}
}

@implementation DynamicPaperManager
- (id)init {
	printf("DynamicPaperManager init\n");

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
			UIImage *image = [UIImage imageWithContentsOfFile:[folderPath stringByAppendingPathComponent:item]];
			self.defaultLightWallpaper = [self imageWithImage:image scaledToSize:CGSizeMake(kScreenHeight, kScreenHeight)];
		}
		if ([item containsString:@"Dark"]) {
			UIImage *image = [UIImage imageWithContentsOfFile:[folderPath stringByAppendingPathComponent:item]];
			self.defaultDarkWallpaper = [self imageWithImage:image scaledToSize:CGSizeMake(kScreenHeight, kScreenHeight)];
		}
	}

	return self;
}

- (void)initialTimer:(id)timer {
	printf("none is nil0\n");

    NSDictionary* userInfo = [[(NSTimer *)timer userInfo] copy];

    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
			for (int i=0; i<4; i++) {
				NSDate *timeSinceSunrise = [NSDate dateWithTimeInterval:[[self eightPics][0][i] doubleValue] sinceDate:self.nextSunrise];
				NSMutableDictionary *wallpaperData = [NSMutableDictionary new];
				UIImage *image = userInfo[[NSString stringWithFormat:@"%d", i]];
				UIImage *wallpaper = [self imageWithImage:image scaledToSize:CGSizeMake(kScreenHeight, kScreenHeight)];
				[wallpaperData setObject:wallpaper forKey:[NSString stringWithFormat:@"sunrise%d", i]];
				PCSimpleTimer *wallpaperTimer = [[PCSimpleTimer alloc] initWithFireDate:timeSinceSunrise
									serviceIdentifier:@"com.miwix.dynamicpaper.service"
									target:self
									selector:@selector(changeWallpaperWithTimer:)
									userInfo:wallpaperData];
				[wallpaperTimer setDisableSystemWaking:YES];
				dispatch_async(dispatch_get_main_queue(), ^{
					NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
					[runLoop addTimer:wallpaperTimer forMode:NSRunLoopCommonModes];
					[runLoop run];
				});
			}
			for (int i=4; i<8; i++) {
				NSDate *timeSinceSunset = [NSDate dateWithTimeInterval:[[self eightPics][1][i-4] doubleValue] sinceDate:self.nextSunset];
				NSMutableDictionary *wallpaperData = [NSMutableDictionary new];
				UIImage *image = userInfo[[NSString stringWithFormat:@"%d", i]];
				UIImage *wallpaper = [self imageWithImage:image scaledToSize:CGSizeMake(kScreenHeight, kScreenHeight)];
				[wallpaperData setObject:wallpaper forKey:[NSString stringWithFormat:@"sunset%d", i]];
				PCSimpleTimer *wallpaperTimer = [[PCSimpleTimer alloc] initWithFireDate:timeSinceSunset
									serviceIdentifier:@"com.miwix.dynamicpaper.service"
									target:self
									selector:@selector(changeWallpaperWithTimer:)
									userInfo:wallpaperData];
				[wallpaperTimer setDisableSystemWaking:YES];
				dispatch_async(dispatch_get_main_queue(), ^{
					NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
					[runLoop addTimer:wallpaperTimer forMode:NSRunLoopCommonModes];
					[runLoop run];
				});
			}
		});
		[timer invalidate];
		[self setWallpaperForCurrentTime];
	});
}

- (void)changeWallpaperWithTimer:(PCSimpleTimer *)timer {
	NSDictionary *userInfo = timer.userInfo;
	UIImage *lightWallpaper = userInfo.allValues[0];
	UIImage *darkWallpaper = userInfo.allValues[0];
	if ([userInfo.allKeys[0] containsString:@"sunset"]) {
		darkWallpaper = self.defaultDarkWallpaper;
	} else {
		lightWallpaper = self.defaultLightWallpaper;
	}
	[self changeWallpaperWithLight:lightWallpaper dark:darkWallpaper];
}

- (void)changeWallpaperWithLight:(UIImage*)arg1 dark:(UIImage*)arg2 {
	printf("changeWallpaperWithLight dark 1\n");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
		setLightAndDarkWallpaperImages(arg1, arg2, 3);
	});
	printf("changeWallpaperWithLight dark 4\n");
}

- (void)setWallpaperForCurrentTime {
    // dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
		printf("setWallpaperForCurrentTime1\n");
		NSMutableArray __block *sunriseTimes = [[NSMutableArray alloc] init];
		NSMutableArray __block *sunsetTimes = [[NSMutableArray alloc] init];
		for (NSNumber *relativeTime in [self eightPics][0]) {
			// printf("relativeTime: %f\n", [relativeTime doubleValue]);
			NSDate *timestamp = [[NSDate alloc] initWithTimeInterval:[relativeTime doubleValue] sinceDate:self.nextSunrise];
			// printf("timestamp: %s\n", [[NSString stringWithFormat:@"%@", timestamp] UTF8String]);
			[sunriseTimes addObject:timestamp];
		}
		for (NSNumber *relativeTime in [self eightPics][1]) {
			// printf("relativeTime: %f\n", [relativeTime doubleValue]);
			NSDate *timestamp = [[NSDate alloc] initWithTimeInterval:[relativeTime doubleValue] sinceDate:self.nextSunset];
			// printf("timestamp: %s\n", [[NSString stringWithFormat:@"%@", timestamp] UTF8String]);
			[sunsetTimes addObject:timestamp];
		}

		printf("setWallpaperForCurrentTime2\n");

		// NSTimeInterval sunriseInterval = fabsl([sunriseTimes[0] timeIntervalSinceDate:[NSDate date]]);
		// printf("initial sunriseInterval: %s\n", [[NSString stringWithFormat:@"%f", sunriseInterval] UTF8String]);
		// NSUInteger indexOfSunriseDate = 0;
		// for (int i=0; i<[sunriseTimes count]; i++) {
		// 	NSTimeInterval sunriseIntervalTest = /*fabsl(*/[sunriseTimes[i] timeIntervalSinceDate:[NSDate date]];//);
		// 	printf("sunriseInterval %d: %s\n", i, [[NSString stringWithFormat:@"%f, fabsl(%f)", sunriseIntervalTest, fabsl(sunriseIntervalTest)] UTF8String]);
		// 	if (fabsl([sunriseTimes[i] timeIntervalSinceDate:[NSDate date]]) < fabsl(sunriseInterval)) {
		// 		sunriseInterval = /*fabsl(*/[sunriseTimes[i] timeIntervalSinceDate:[NSDate date]];//);
		// 		indexOfSunriseDate = i;
		// 	}
		// }

		// NSTimeInterval sunsetInterval = fabsl([sunsetTimes[0] timeIntervalSinceDate:[NSDate date]]);
		// printf("initial sunsetInterval: %s\n", [[NSString stringWithFormat:@"%f", sunsetInterval] UTF8String]);
		// NSUInteger indexOfSunsetDate = 0;
		// for (int i=0; i<[sunsetTimes count]; i++) {
		// 	NSTimeInterval sunsetIntervalTest = /*fabsl(*/[sunsetTimes[i] timeIntervalSinceDate:[NSDate date]];//);
		// 	printf("sunsetInterval %d: %s\n", i, [[NSString stringWithFormat:@"%f, fabsl(%f)", sunsetIntervalTest, fabsl(sunsetIntervalTest)] UTF8String]);
		// 	if (fabsl([sunsetTimes[i] timeIntervalSinceDate:[NSDate date]]) < fabsl(sunsetInterval)) {
		// 		sunsetInterval = /*fabsl(*/[sunsetTimes[i] timeIntervalSinceDate:[NSDate date]];//);
		// 		indexOfSunsetDate = i;
		// 	}
		// }

		// printf("indexOfSunriseDate: %s, sunriseInterval: %s\n", [[NSString stringWithFormat:@"%d", indexOfSunriseDate] UTF8String], [[NSString stringWithFormat:@"%f", sunriseInterval] UTF8String]);
		// printf("indexOfSunsetDate: %s, sunsetInterval: %s\n", [[NSString stringWithFormat:@"%d", indexOfSunsetDate] UTF8String], [[NSString stringWithFormat:@"%f", sunsetInterval] UTF8String]);

		NSDate *mostRecentDate = [NSDate distantPast];
		for (NSDate *date in sunsetTimes) {
			if ([date timeIntervalSinceNow] <= 0) {
				mostRecentDate = [date laterDate:mostRecentDate];
			}
			printf("[date timeIntervalSinceNow] 1: %lf\n", [date timeIntervalSinceNow]);
		}
		bool afterSunrise = [mostRecentDate isEqualToDate:[NSDate distantPast]];
		if (afterSunrise == true) {
			for (NSDate *date in sunriseTimes) {
				if ([date timeIntervalSinceNow] <= 0) {
					mostRecentDate = [date laterDate:mostRecentDate];
				}
				printf("[date timeIntervalSinceNow] 1: %lf\n", [date timeIntervalSinceNow]);
			}
		}
		long index = afterSunrise ? [sunriseTimes indexOfObject:mostRecentDate] : [sunsetTimes indexOfObject:mostRecentDate];
		if ([mostRecentDate isEqualToDate:[NSDate distantPast]] == true) index = [sunsetTimes count]-1;
		printf("index: %ld\n", index);

		NSString *homeDirectory = [[NSHomeDirectory() stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"root"];
		NSString *folderPath = [homeDirectory stringByAppendingPathComponent:@"pics/pics"];
		NSArray *folderItems = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
		folderItems = [folderItems sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
		NSUInteger finalIndex;
		if (afterSunrise == true && [mostRecentDate isEqualToDate:[NSDate distantPast]] == false) {
			finalIndex = index;
			printf("setWallpaperForCurrentTime41\n");
			UIImage *tempWallpaper = [UIImage imageWithContentsOfFile:[folderPath stringByAppendingPathComponent:folderItems[finalIndex]]];
			UIImage *wallpaper = [self imageWithImage:tempWallpaper scaledToSize:CGSizeMake(kScreenHeight, kScreenHeight)];
			printf("setWallpaperForCurrentTime4\n");
			if (index <= 1) [self changeWallpaperWithLight:wallpaper dark:[wallpaper copy]];
			else [self changeWallpaperWithLight:wallpaper dark:self.defaultDarkWallpaper];
		} else {
			finalIndex = index+4;
			printf("setWallpaperForCurrentTime51\n");
			UIImage *tempWallpaper = [UIImage imageWithContentsOfFile:[folderPath stringByAppendingPathComponent:folderItems[finalIndex]]];
			UIImage *wallpaper = [self imageWithImage:tempWallpaper scaledToSize:CGSizeMake(kScreenHeight, kScreenHeight)];
			printf("setWallpaperForCurrentTime5\n");
			if (index <= 1) [self changeWallpaperWithLight:wallpaper dark:[wallpaper copy]];
			else [self changeWallpaperWithLight:self.defaultLightWallpaper dark:wallpaper];
		}
		printf("setWallpaperForCurrentTime6\n");
	// });
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    return newImage;
}
@end
