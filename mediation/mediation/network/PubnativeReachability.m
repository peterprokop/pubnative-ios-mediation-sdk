/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Basic demonstration of how to use the SystemConfiguration Reachablity APIs.
 */

#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <sys/socket.h>

#import <CoreFoundation/CoreFoundation.h>

#import "PubnativeReachability.h"

NSString *kPubnativeReachabilityChangedNotification = @"kNetworkReachabilityChangedNotification";

#pragma mark - Supporting functions

#define kPubnativeShouldPrintReachabilityFlags 1

static void PubnativePrintReachabilityFlags(SCNetworkReachabilityFlags flags, const char* comment) __attribute__((annotate("oclint:suppress[bitwise operator in conditional]"))) //!OCLint
{
#if kPubnativeShouldPrintReachabilityFlags

    NSLog(@"Reachability Flag Status: %c%c %c%c%c%c%c%c%c %s\n",
          (flags & kSCNetworkReachabilityFlagsIsWWAN)				? 'W' : '-',
          (flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',

          (flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)  ? 'C' : '-',
          (flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-',
          (flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',
          (flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-',
          comment
          );
#endif
}


static void PubnativeReachabilityCallback(SCNetworkReachabilityRef target,
                                          SCNetworkReachabilityFlags flags,
                                          void* info)
{
#pragma unused (target, flags)
	NSCAssert(info != NULL, @"info was NULL in ReachabilityCallback");
	NSCAssert([(__bridge NSObject*) info isKindOfClass: [PubnativeReachability class]],
              @"info was wrong class in ReachabilityCallback");

    PubnativeReachability* noteObject = (__bridge PubnativeReachability *)info;
    // Post a notification to notify the client that the network reachability changed.
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter postNotificationName: kPubnativeReachabilityChangedNotification
                                 object: noteObject];
}


#pragma mark - Reachability implementation

@implementation PubnativeReachability

+ (instancetype)reachabilityWithHostName:(NSString *)hostName
{
	PubnativeReachability* returnValue = NULL;
	SCNetworkReachabilityRef reachability =
        SCNetworkReachabilityCreateWithName(NULL,[hostName UTF8String]);
	if (reachability != NULL) {
		returnValue = [[self alloc] init];
		if (returnValue == NULL)
		{
            CFRelease(reachability);
		} else {
            returnValue.reachabilityRef = reachability;
            returnValue.alwaysReturnLocalWiFiStatus = NO;
        }
	}
	return returnValue;
}


+ (instancetype)reachabilityWithAddress:(const struct sockaddr_in *)hostAddress
{
	SCNetworkReachabilityRef reachability =
        SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault,
                                               (const struct sockaddr *)hostAddress);
	PubnativeReachability* returnValue = NULL;
	if (reachability != NULL) {
		returnValue = [[self alloc] init];
		if (returnValue == NULL) {
			CFRelease(reachability);
		} else {
            returnValue.reachabilityRef = reachability;
            returnValue.alwaysReturnLocalWiFiStatus = NO;
        }
	}
	return returnValue;
}



+ (instancetype)reachabilityForInternetConnection
{
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
    
	return [self reachabilityWithAddress:&zeroAddress];
}


+ (instancetype)reachabilityForLocalWiFi
{
	struct sockaddr_in localWifiAddress;
	bzero(&localWifiAddress, sizeof(localWifiAddress));
	localWifiAddress.sin_len = sizeof(localWifiAddress);
	localWifiAddress.sin_family = AF_INET;

	// IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0.
	localWifiAddress.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);//!OCLint(Used constant from netinet)

	PubnativeReachability* returnValue = [self reachabilityWithAddress: &localWifiAddress];
	if (returnValue != NULL)
	{
		returnValue.alwaysReturnLocalWiFiStatus = YES;
	}
    
	return returnValue;
}


#pragma mark - Start and stop notifier

- (BOOL)startNotifier
{
	BOOL returnValue = NO;
	SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};

	if (SCNetworkReachabilitySetCallback(self.reachabilityRef,
                                         PubnativeReachabilityCallback,
                                         &context) &&
        SCNetworkReachabilityScheduleWithRunLoop(self.reachabilityRef,
                                                 CFRunLoopGetCurrent(),
                                                 kCFRunLoopDefaultMode))
	{
        returnValue = YES;
	}
    
	return returnValue;
}


- (void)stopNotifier
{
	if (self.reachabilityRef != NULL)
	{
		SCNetworkReachabilityUnscheduleFromRunLoop(self.reachabilityRef,
                                                   CFRunLoopGetCurrent(),
                                                   kCFRunLoopDefaultMode);
	}
}


- (void)dealloc
{
	[self stopNotifier];
	if (self.reachabilityRef != NULL)
	{
		CFRelease(self.reachabilityRef);
	}
}


#pragma mark - Network Flag Handling

- (PubnativeNetworkStatus)localWiFiStatusForFlags:(SCNetworkReachabilityFlags)flags
{
	PubnativePrintReachabilityFlags(flags, "localWiFiStatusForFlags");
	PubnativeNetworkStatus returnValue = PubnativeNetworkStatus_NotReachable;
    
    int flagReachable = flags & kSCNetworkReachabilityFlagsReachable;
    int flagIsDirect = flags & kSCNetworkReachabilityFlagsIsDirect;

	if (flagReachable && flagIsDirect)
	{
		returnValue = PubnativeNetworkStatus_ReachableViaWiFi;
	}
    
	return returnValue;
}


- (PubnativeNetworkStatus)networkStatusForFlags:(SCNetworkReachabilityFlags)flags
{
	PubnativePrintReachabilityFlags(flags, "networkStatusForFlags");
    
    int flagReachable = flags & kSCNetworkReachabilityFlagsReachable;
    int flagConnectionRequired = flags & kSCNetworkReachabilityFlagsConnectionRequired;
    int flagConnectionOnDemand = flags & kSCNetworkReachabilityFlagsConnectionOnDemand;
    int flagConnectionOnTraffic = flags & kSCNetworkReachabilityFlagsConnectionOnTraffic;
    int flagInterventionRequired = flags & kSCNetworkReachabilityFlagsInterventionRequired;
    int flagIsWWAN = flags & kSCNetworkReachabilityFlagsIsWWAN;
    
	if (flagReachable == 0)
	{
		// The target host is not reachable.
		return PubnativeNetworkStatus_NotReachable;
	}

    PubnativeNetworkStatus returnValue = PubnativeNetworkStatus_NotReachable;

	if (flagConnectionRequired == 0)
	{
		/*
         If the target host is reachable and no connection is required 
         then we'll assume (for now) that you're on Wi-Fi...
         */
		returnValue = PubnativeNetworkStatus_ReachableViaWiFi;
	}

	if (((flagConnectionOnDemand != 0) ||
        flagConnectionOnTraffic) &&
        flagInterventionRequired)
	{
        /*
         ... and the connection is on-demand (or on-traffic) 
         if the calling application is using the CFSocketStream or higher APIs 
         and no [user] intervention is needed...
        */
            returnValue = PubnativeNetworkStatus_ReachableViaWiFi;
    }

	if (flagIsWWAN == kSCNetworkReachabilityFlagsIsWWAN)
	{
		/*
         ... but WWAN connections are OK 
         if the calling application is using the CFNetwork APIs.
         */
		returnValue = PubnativeNetworkStatus_ReachableViaWWAN;
	}
    
	return returnValue;
}


- (BOOL)connectionRequired
{
	NSAssert(self.reachabilityRef != NULL,
             @"connectionRequired called with NULL reachabilityRef");
	SCNetworkReachabilityFlags flags;

	if (SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags))
	{
		return (flags & kSCNetworkReachabilityFlagsConnectionRequired);
	}

    return NO;
}


- (PubnativeNetworkStatus)currentReachabilityStatus
{
	NSAssert(self.reachabilityRef != NULL,
             @"currentNetworkStatus called with NULL SCNetworkReachabilityRef");
	PubnativeNetworkStatus returnValue = PubnativeNetworkStatus_NotReachable;
	SCNetworkReachabilityFlags flags;
    
	if (SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags))
	{
		if (self.alwaysReturnLocalWiFiStatus)
		{
			returnValue = [self localWiFiStatusForFlags:flags];
		}
		else
		{
			returnValue = [self networkStatusForFlags:flags];
		}
	}
    
	return returnValue;
}


@end
