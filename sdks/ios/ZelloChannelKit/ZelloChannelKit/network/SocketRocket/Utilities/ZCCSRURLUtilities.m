//
// Copyright (c) 2016-present, Facebook, Inc.
// All rights reserved.
//
// This source code is licensed under the BSD-style license found in the
// LICENSE file in the root directory of this source tree. An additional grant
// of patent rights can be found in the PATENTS file in the same directory.
//

#import "ZCCSRURLUtilities.h"

#import "ZCCSRHash.h"

NS_ASSUME_NONNULL_BEGIN

NSString *ZCCSRURLOrigin(NSURL *url)
{
    NSMutableString *origin = [NSMutableString string];

    NSString *scheme = url.scheme.lowercaseString;
    if ([scheme isEqualToString:@"wss"]) {
        scheme = @"https";
    } else if ([scheme isEqualToString:@"ws"]) {
        scheme = @"http";
    }
    [origin appendFormat:@"%@://%@", scheme, url.host];

    NSNumber *port = url.port;
    BOOL portIsDefault = (!port ||
                          ([scheme isEqualToString:@"http"] && port.integerValue == 80) ||
                          ([scheme isEqualToString:@"https"] && port.integerValue == 443));
    if (!portIsDefault) {
        [origin appendFormat:@":%@", port.stringValue];
    }
    return origin;
}

extern BOOL ZCCSRURLRequiresSSL(NSURL *url)
{
    NSString *scheme = url.scheme.lowercaseString;
    return ([scheme isEqualToString:@"wss"] || [scheme isEqualToString:@"https"]);
}

extern NSString *_Nullable ZCCSRBasicAuthorizationHeaderFromURL(NSURL *url)
{
    NSData *data = [[NSString stringWithFormat:@"%@:%@", url.user, url.password] dataUsingEncoding:NSUTF8StringEncoding];
    return [NSString stringWithFormat:@"Basic %@", ZCCSRBase64EncodedStringFromData(data)];
}

extern NSString *_Nullable ZCCSRStreamNetworkServiceTypeFromURLRequest(NSURLRequest *request)
{
    NSString *networkServiceType = nil;
    switch (request.networkServiceType) {
        case NSURLNetworkServiceTypeDefault:
      case NSURLNetworkServiceTypeResponsiveData:
            break;
        case NSURLNetworkServiceTypeVoIP:
            networkServiceType = NSStreamNetworkServiceTypeVoIP;
            break;
        case NSURLNetworkServiceTypeVideo:
            networkServiceType = NSStreamNetworkServiceTypeVideo;
            break;
        case NSURLNetworkServiceTypeBackground:
            networkServiceType = NSStreamNetworkServiceTypeBackground;
            break;
        case NSURLNetworkServiceTypeVoice:
            networkServiceType = NSStreamNetworkServiceTypeVoice;
            break;
#if (__MAC_OS_X_VERSION_MAX_ALLOWED >= 101200 || __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000 || __TV_OS_VERSION_MAX_ALLOWED >= 100000 || __WATCH_OS_VERSION_MAX_ALLOWED >= 30000)
        case NSURLNetworkServiceTypeCallSignaling:
          if (@available(iOS 10, *)) {
            networkServiceType = NSStreamNetworkServiceTypeCallSignaling;
          }
            break;
#endif
    }
    return networkServiceType;
}

NS_ASSUME_NONNULL_END
