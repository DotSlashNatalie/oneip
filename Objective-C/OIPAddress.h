//
//  OIPAddress.h
//  oneIP
//
//  Created by Bret Deasy on 7/17/13.
//  Copyright (c) 2013 Bret Deasy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BitArray.h"
#import "OIPUtility.h"

typedef enum {
    kIPv4,
    kIPv6
} IPVersion;

@interface OIPAddress : NSObject
{
    @public
    IPVersion ipVersion;
    @private
    BitArray *cidr;
    BitArray *ipAddress;
}

- (id)init;
- (id)initWithString:(NSString *)ipAddr;
- (BOOL)isValidIPv4:(NSString *)ipAddrString;
- (BOOL)isValidIPv6:(NSString *)ipAddrString;
- (IPVersion)ipVersion;
- (NSString *)subnetMask;
- (BitArray *)ipAddressAsBitArray;
- (NSString *)ipAddress;
- (NSString *)firstAddress;
- (NSString *)lastAddress;
- (NSString *)networkAddress;
- (NSString *)broadcastAddress;
- (NSArray *)ipRange;
- (BOOL)isAddressInRange:(OIPAddress *)address;

@end
