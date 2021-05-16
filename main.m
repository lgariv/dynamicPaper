#import "main.h"

int main(int argc, char *argv[], char *envp[]) {
	@autoreleasepool {
		// DynamicPaperManager *daemon = [DynamicPaperManager new];

		// printf("%s\n", [[NSString stringWithFormat:@"%@", [daemon nextSunrise]] UTF8String]);
		// printf("%s\n", [[NSString stringWithFormat:@"%@", [daemon nextSunset]] UTF8String]);
		// return 0;

        // NSString *folderPath = [[NSString alloc] initWithCString:argv[0] encoding:NSUTF8StringEncoding];
		NSString *folderPath = [NSHomeDirectory() stringByAppendingPathComponent:@"pics/pics"];
		NSArray *folderItems = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
		folderItems = [folderItems sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
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
	folderItems = [folderItems sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	for (NSString *item in folderItems) {
		if ([item containsString:@"Light"]) {
			UIImage *image = [UIImage imageWithContentsOfFile:[folderPath stringByAppendingPathComponent:item]];
			self.defaultLightWallpaper = [self imageWithImage:image scaledToSize:CGSizeMake([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.height)];
		}
		if ([item containsString:@"Dark"]) {
			UIImage *image = [UIImage imageWithContentsOfFile:[folderPath stringByAppendingPathComponent:item]];
			self.defaultDarkWallpaper = [self imageWithImage:image scaledToSize:CGSizeMake([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.height)];
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

    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
		for (int i=0; i<4; i++) {
			NSDate *timeSinceSunrise = [NSDate dateWithTimeInterval:[[self eightPics][0][i] doubleValue] sinceDate:self.nextSunrise];
			NSMutableDictionary *wallpaperData = [NSMutableDictionary new];
			UIImage *image = userInfo[[NSString stringWithFormat:@"%d", i]];
			UIImage *wallpaper = [self imageWithImage:image scaledToSize:CGSizeMake([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.height)];
			[wallpaperData setObject:wallpaper forKey:[NSString stringWithFormat:@"sunrise%d", i]];
			PCSimpleTimer *wallpaperTimer = [[PCSimpleTimer alloc] initWithFireDate:timeSinceSunrise
								serviceIdentifier:@"com.miwix.dynamicpaper.service"
								target:self
								selector:@selector(changeWallpaper:)
								userInfo:wallpaperData];
			[wallpaperTimer setDisableSystemWaking:YES];
			dispatch_async(dispatch_get_main_queue(), ^{
				NSRunLoop *runLoop = [NSRunLoop mainRunLoop];
				[runLoop addTimer:wallpaperTimer forMode:NSDefaultRunLoopMode];
				[runLoop run];
			});
		}
		for (int i=4; i<8; i++) {
			NSDate *timeSinceSunset = [NSDate dateWithTimeInterval:[[self eightPics][1][i-4] doubleValue] sinceDate:self.nextSunset];
			NSMutableDictionary *wallpaperData = [NSMutableDictionary new];
			UIImage *image = userInfo[[NSString stringWithFormat:@"%d", i]];
			UIImage *wallpaper = [self imageWithImage:image scaledToSize:CGSizeMake([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.height)];
			[wallpaperData setObject:wallpaper forKey:[NSString stringWithFormat:@"sunset%d", i]];
			PCSimpleTimer *wallpaperTimer = [[PCSimpleTimer alloc] initWithFireDate:timeSinceSunset
								serviceIdentifier:@"com.miwix.dynamicpaper.service"
								target:self
								selector:@selector(changeWallpaper:)
								userInfo:wallpaperData];
			[wallpaperTimer setDisableSystemWaking:YES];
			dispatch_async(dispatch_get_main_queue(), ^{
				NSRunLoop *runLoop = [NSRunLoop mainRunLoop];
				[runLoop addTimer:wallpaperTimer forMode:NSDefaultRunLoopMode];
				[runLoop run];
			});
		}
			[timer invalidate];
			[self setWallpaperForCurrentTime];
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

		// printf("sunriseTimes: %s\n", [[NSString stringWithFormat:@"%@", [sunriseTimes description]] UTF8String]);
		// printf("sunsetTimes: %s\n", [[NSString stringWithFormat:@"%@", [sunsetTimes description]] UTF8String]);

		NSTimeInterval sunriseInterval = fabsl([sunriseTimes[0] timeIntervalSinceDate:[NSDate date]]);
		printf("initial sunriseInterval: %s\n", [[NSString stringWithFormat:@"%f", sunriseInterval] UTF8String]);
		NSUInteger indexOfSunriseDate = 0;
		// for (NSDate *date in sunriseTimes) {
		for (int i=1; i<[sunriseTimes count]; i++) {
			if (fabsl([sunriseTimes[i] timeIntervalSinceDate:[NSDate date]]) < sunriseInterval) {
				sunriseInterval = fabsl([sunriseTimes[i] timeIntervalSinceDate:[NSDate date]]);
				printf("sunriseInterval %d: %s\n", i, [[NSString stringWithFormat:@"%f", sunriseInterval] UTF8String]);
				indexOfSunriseDate = i;
			}
		}

		NSTimeInterval sunsetInterval = fabsl([sunsetTimes[0] timeIntervalSinceDate:[NSDate date]]);
		printf("initial sunsetInterval: %s\n", [[NSString stringWithFormat:@"%f", sunsetInterval] UTF8String]);
		NSUInteger indexOfSunsetDate = 0;
		// for (NSDate *date in sunsetTimes) {
		for (int i=1; i<[sunsetTimes count]; i++) {
			if (fabsl([sunsetTimes[i] timeIntervalSinceDate:[NSDate date]]) < sunsetInterval) {
				sunsetInterval = fabsl([sunsetTimes[i] timeIntervalSinceDate:[NSDate date]]);
				printf("sunsetInterval %d: %s\n", i, [[NSString stringWithFormat:@"%f", sunsetInterval] UTF8String]);
				indexOfSunsetDate = i;
			}
		}

		printf("indexOfSunriseDate: %s, sunriseInterval: %s\n", [[NSString stringWithFormat:@"%d", indexOfSunriseDate] UTF8String], [[NSString stringWithFormat:@"%f", sunriseInterval] UTF8String]);
		printf("indexOfSunsetDate: %s, sunsetInterval: %s\n", [[NSString stringWithFormat:@"%d", indexOfSunsetDate] UTF8String], [[NSString stringWithFormat:@"%f", sunsetInterval] UTF8String]);

		NSString *folderPath = [NSHomeDirectory() stringByAppendingPathComponent:@"pics/pics"];
		NSArray *folderItems = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
		folderItems = [folderItems sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
		NSUInteger finalIndex;
		if (sunriseInterval <= sunsetInterval) {
			finalIndex = indexOfSunriseDate;
			UIImage *tempWallpaper = [UIImage imageWithContentsOfFile:[folderPath stringByAppendingPathComponent:folderItems[finalIndex]]];
			UIImage *wallpaper = [self imageWithImage:tempWallpaper scaledToSize:CGSizeMake([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.height)];
			printf("setWallpaperForCurrentTime41\n");
			// dispatch_sync(dispatch_get_main_queue(), ^{
				printf("setWallpaperForCurrentTime4\n");
				setLightAndDarkWallpaperImages(wallpaper, [self imageWithImage:self.defaultDarkWallpaper scaledToSize:CGSizeMake([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.height)], 3);
			// });
		} else {
			finalIndex = indexOfSunsetDate;
			UIImage *tempWallpaper = [UIImage imageWithContentsOfFile:[folderPath stringByAppendingPathComponent:folderItems[finalIndex+4]]];
			UIImage *wallpaper = [self imageWithImage:tempWallpaper scaledToSize:CGSizeMake([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.height)];
			printf("setWallpaperForCurrentTime51\n");
			// dispatch_sync(dispatch_get_main_queue(), ^{
				printf("setWallpaperForCurrentTime5\n");
				setLightAndDarkWallpaperImages([self imageWithImage:self.defaultLightWallpaper scaledToSize:CGSizeMake([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.height)], wallpaper, 3);
			// });
		}
		printf("setWallpaperForCurrentTime6\n");
	});
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
