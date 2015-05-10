//
//  OIPAddress.m
//  oneIP
//
//  Created by Bret Deasy on 7/17/13.
//  Copyright (c) 2013 Bret Deasy. All rights reserved.
//

#import "OIPAddress.h"

#define INVALID_IP_ERROR_NAME       @"InvalidIPAddressError"
#define INVALID_IP_ERROR_REASON     @"The IP address appears to be invalid."
#define INVALID_CIDR_ERROR_NAME     @"InvalidCIDRError"
#define INVALID_CIDR_ERROR_REASON   @"The CIDR appears to be invalid."

@implementation OIPAddress

/**
 Returns a OIPAddress with IP address 192.168.1.1 and CIDR 24
 **/
- (id)init
{
    return [self initWithString:@"192.168.1.1/24"];
}

/**
 Returns a OIPAddress with specified IP address and CIDR
 **/
- (id)initWithString:(NSString *)ipAddr
{
    self = [super init];
    
    if (self)
    {
        cidr = [[BitArray alloc] init];
        ipAddress = [[BitArray alloc] init];
        
        if ([self isValidIPv4:ipAddr])
        {
            [self setIPv4:ipAddr];
        } else if ([self isValidIPv6:ipAddr]) {
            [self setIPv6:ipAddr];
        } else {
            @throw [NSException exceptionWithName:INVALID_IP_ERROR_NAME
                                           reason:INVALID_IP_ERROR_REASON
                                         userInfo:nil];
        }
    }
    
    return self;
}

/**
 Returns true if ipAddrString is a valid IPv4 address.
 **/
- (BOOL)isValidIPv4:(NSString *)ipAddrString
{
    NSArray *ipAddrArray;
    
    if ([ipAddrString rangeOfString:@"/"].location != NSNotFound)
    {
        ipAddrArray = [ipAddrString componentsSeparatedByString:@"/"];
        
        if ([ipAddrArray count] == 2)
        {
            int _cidr = [[ipAddrArray objectAtIndex:1] intValue];
            
            if (_cidr < 0 || _cidr > 32)
            {
                return NO;
            }
        } else if ([ipAddrArray count] > 2) {
            return NO;
        }
        
        ipAddrArray = [[ipAddrArray objectAtIndex:0] componentsSeparatedByString:@"."];

    } else {
        ipAddrArray = [ipAddrString componentsSeparatedByString:@"."];
    }
    
    for (int i = 0; i < [ipAddrArray count]; i++)
    {
        int oct = [[ipAddrArray objectAtIndex:i] intValue];
        
        if (oct < 0 || oct > 255)
        {
            return NO;
        }
    }
    
    return YES;
}

/**
 Returns true if ipAddrString is a valid IPv6 address.
 **/
- (BOOL)isValidIPv6:(NSString *)ipAddrString
{
    NSArray *ipAddrArray;
    
    if ([ipAddrString rangeOfString:@":"].location == NSNotFound)
    {
        return NO;
    }
    if ([ipAddrString rangeOfString:@"/"].location != NSNotFound)
    {
        ipAddrArray = [ipAddrString componentsSeparatedByString:@"/"];
        
        if ([ipAddrArray count] == 2)
        {
            int _cidr = [[ipAddrArray objectAtIndex:1] intValue];
            
            if (_cidr < 0 || _cidr > 128)
            {
                return NO;
            }
        } else {
            return NO;
        }
        
        ipAddrArray = [[ipAddrArray objectAtIndex:0] componentsSeparatedByString:@":"];
        
    } else {
        ipAddrArray = [ipAddrString componentsSeparatedByString:@":"];
    }
    
    for (int i = 0; i < [ipAddrArray count]; i++)
    {
        int oct = [OIPUtility hexStringToDecimal:[ipAddrArray objectAtIndex:i]];
        
        if (oct < 0 || oct > 0xffff)
        {
            return NO;
        }
    }
    
    return YES;
}

/**
 Sets the ipAddress, cidr, and ipVersion for IPv6 address.
 **/
- (void)setIPv6:(NSString *)ipAddrString
{
    NSArray *ipAddrArray;
    NSArray *newIPAddrArray;
    
    if ([ipAddrString rangeOfString:@"/"].location != NSNotFound)
    {
        ipAddrArray = [ipAddrString componentsSeparatedByString:@"/"];
        
        [self setCIDR:[[ipAddrArray objectAtIndex:1] intValue]  withNumberOfBits:128];
        
        ipAddrArray = [[ipAddrArray objectAtIndex:0] componentsSeparatedByString:@":"];
    } else {
        ipAddrArray = [ipAddrString componentsSeparatedByString:@":"];
    }
    
    newIPAddrArray = [self fillIPv6Address:[ipAddrArray componentsJoinedByString:@":"]];
    
    for (int i = 0; i < [ipAddrArray count]; i++)
    {
        CFIndex index = i * 16;
        int oct = [OIPUtility hexStringToDecimal:[ipAddrArray objectAtIndex:i]];
        BitArray *octBitArray = [[BitArray alloc] initWithInteger:oct];
        [octBitArray padToCapacity:16];
        
        [ipAddress insertBitArray:octBitArray atIndex:index];
    }
    
    ipVersion = kIPv6;
}

/**
 Sets the ipAddress, cidr, and ipVersion for IPv4 address.
**/
- (void)setIPv4:(NSString *)ipAddrString
{
    NSArray *ipAddrArray;
    
    if ([ipAddrString rangeOfString:@"/"].location != NSNotFound)
    {
        NSArray *ipCIDRArray = [ipAddrString componentsSeparatedByString:@"/"];
        ipAddrArray = [[ipCIDRArray objectAtIndex:0] componentsSeparatedByString:@"."];
        
        [self setCIDR:[[ipCIDRArray objectAtIndex:1] intValue] withNumberOfBits:32];
    } else {
        ipAddrArray = [ipAddrString componentsSeparatedByString:@"."];
    }
    
//    [ipAddress setCount:32];
    
    for (int i = 0; i < [ipAddrArray count]; i++)
    {
        CFIndex index = i * 8;
        BitArray *octBitArray = [[BitArray alloc] initWithInteger:[[ipAddrArray objectAtIndex:i] intValue]];
        [octBitArray padToCapacity:8];
        
        [ipAddress insertBitArray:octBitArray atIndex:index];
    }
    
    ipVersion = kIPv4;
}



/**
 Returns the IP Version of OIPAddress.
 **/
- (IPVersion)ipVersion
{
    return ipVersion;
}

/**
 Sets cidr
 **/
- (void)setCIDR:(int)value withNumberOfBits:(int)numOfBits
{
    [cidr setCount:numOfBits];
    CFBit bit;
    
    for (int i = 0; i < numOfBits; i++)
    {
        bit = (i < value);
        [cidr setBitAtIndex:i toValue:bit];
    }
}

/**
 Returns the Subnet Mask of the receiver's IP Address
 **/
- (NSString *)subnetMask
{
    return [self calculateAddress:cidr];
}

/**
 Returns the readable IPv4 address from the BitArray passed to the method.
 **/
- (NSString *)calculateIPv4Address:(BitArray *)bitArray
{
    int byteValue = 0;
    CFRange range;
    
    NSString *format = (ipVersion == kIPv4) ? @"%d." : @"%x:";
    
    NSMutableString *ipString = [NSMutableString stringWithString:@""];
    
    for (int i = 0; i < [bitArray count] / 8; i++)
    {
        range = CFRangeMake(i *8, 8);
        
        byteValue = [bitArray bitsInRange:range];
        
        [ipString appendFormat:format, byteValue];
    }
    
    return ipString;
}

/**
 Returns the readable IPv6 address from the BitArray passed to the method.
 **/
- (NSString *)calculateIPv6Address:(BitArray *)bitArray
{
    int byteValue = 0;
    CFRange range;
    
    NSString *format = (ipVersion == kIPv4) ? @"%d." : @"%x:";
    
    NSMutableString *ipString = [NSMutableString stringWithString:@""];
    
    for (int i = 0; i < [bitArray count] / 8; i++)
    {
        range = CFRangeMake(i * 16, 16);
        
        byteValue = [bitArray bitsInRange:range];
        
        [ipString appendString:[NSString stringWithFormat:format, byteValue]];
    }
    
    return ipString;
}

/**
 Returns the readable address from the given BitArray.
 **/
//Consolidates the previous calculate(IPv4/IPv6)Address: method
- (NSString *)calculateAddress:(BitArray *)bitArray
{
    CFRange range;
    int byteValue;
    NSString *format = (ipVersion == kIPv4) ? @"%d." : @"%x:";
    NSMutableString *ipString = [NSMutableString stringWithString:@""];
    
    int bitSize = (ipVersion == kIPv4) ? 8 : 16;
    
    for (int i = 0; i < [bitArray count] / bitSize; i++)
    {
        
        range = CFRangeMake(i * bitSize, bitSize);
        
        byteValue = [bitArray bitsInRange:range];
        
        [ipString appendFormat:format, byteValue];
    }
    
    return [ipString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:(ipVersion == kIPv4) ? @"." : @":"]];;
}

/**
 Returns the receiver's IP address as a BitArray
 **/
- (BitArray *)ipAddressAsBitArray
{
    return ipAddress;
}

/**
 Returns the receiver's readable IP address
 **/
- (NSString *)ipAddress
{
    return [self calculateAddress:ipAddress];
}

/**
 Returns the first address in the receiver's IP range
 **/
- (NSString *)firstAddress
{
    return [self calculateAddress:[self calculateFirstAddress]];
}

/**
 Calculates the first IP address in the receiver's IP range
 **/
- (BitArray *)calculateFirstAddress
{
    //ipv4 formula => (ip & cidr) + 1
    //ipv6 formula => (ip & cidr)
    BitArray *retBitArray = [ipAddress bitArrayByANDingWithBitArray:cidr];
    
    if (ipVersion == kIPv4)
    {
        retBitArray = [retBitArray bitArrayByAddingInteger:1];
    }
    
    return retBitArray;
}
/**
 Calculates the first IPv4 address in the receiver's IP range
 **/
- (BitArray *)calculateIPv4FirstAddress
{
    //formula => (ip & cidr) + 1
    BitArray *retBitArray = [ipAddress bitArrayByANDingWithBitArray:cidr];
    retBitArray = [retBitArray bitArrayByAddingInteger:1];
    
    return retBitArray;
}

/**
 Returns the last address in the receiver's IP range
 **/
- (NSString *)lastAddress
{
    return [self calculateAddress:[self calculateLastAddress]];
}

/**
 Calculates the last IP address in the receiver's IP range
 **/
- (BitArray *)calculateLastAddress
{
    //formula ipv4 => (ip | !cidr) - 1
    //formula ipv6 => (ip | !cidr)
    BitArray *cidrNOT = [cidr bitArrayByNOTingBitArray];
    BitArray *retBitArray = [ipAddress bitArrayByORingWithBitArray:cidrNOT];
    
    if (ipVersion == kIPv4)
    {
        retBitArray = [retBitArray bitArrayBySubtractingInteger:1];
    }
    
    return  retBitArray;
}

/**
 Calculates the last IPv4 address in the receiver's IP range
 **/
- (BitArray *)calculateIPv4LastAddress
{
    //formula => (ip | cidr) - 1
    BitArray *cidrNOT = [cidr bitArrayByNOTingBitArray];
    BitArray *retBitArray = [ipAddress bitArrayByORingWithBitArray:cidrNOT];
    retBitArray = [retBitArray bitArrayBySubtractingInteger:1];
    
    return retBitArray;
}

/**
 Returns the receiver's network address
 **/
- (NSString *)networkAddress
{
    if (ipVersion == kIPv4)
    {
        return [self calculateAddress:[self calculateNetworkAddress]];
    }
    
    return nil;
}

/**
 Calculates the receiver's network address
 **/
- (BitArray *)calculateNetworkAddress
{
    //formula = ip & cidr
    return [ipAddress bitArrayByANDingWithBitArray:cidr];
}

/**
 Returns the receiver's broadcast address
 **/
- (NSString *)broadcastAddress
{
    if (ipVersion == kIPv4)
    {
        return [self calculateAddress:[self calculateBroadcastAddress]];
    }
    
    return nil;
}

/**
 Calculates the receiver's broadcast address
 **/
- (BitArray *)calculateBroadcastAddress
{
    BitArray *cidrNot = [cidr bitArrayByNOTingBitArray];
    BitArray *retBitArray = [ipAddress bitArrayByORingWithBitArray:cidrNot];
    
    return retBitArray;
}

/**
 Returns the receiver's IP range
 **/
- (NSArray *)ipv4Range
{
    NSMutableArray *ipAddrArray = [[NSMutableArray alloc] init];
    
    BitArray *currentIP = [self calculateIPv4FirstAddress];
    BitArray *lastIP = [self calculateIPv4LastAddress];
    
    while ([currentIP lessThanOrEqualToBitArray:lastIP])
    {
        [ipAddrArray addObject:[self calculateAddress:currentIP]];
        currentIP = [currentIP bitArrayByAddingInteger:1];
    }
    
    return ipAddrArray;
}

/**
 Returns the receiver's IP range
 **/
- (NSArray *)ipRange
{
    NSMutableArray *ipAddrArray = [[NSMutableArray alloc] init];
    
    BitArray *currentIP = [self calculateFirstAddress];
    BitArray *lastIP = [self calculateLastAddress];
    
    while ([currentIP lessThanOrEqualToBitArray:lastIP])
    {
        [ipAddrArray addObject:[self calculateAddress:currentIP]];
        currentIP = [currentIP bitArrayByAddingInteger:1];
    }
    
    return ipAddrArray;
}

/**
 Returns true if the given IP address is in the receiver's IP range
 **/
- (BOOL)isAddressInRange:(OIPAddress *)address
{
    BitArray *_ipAddress = [address ipAddressAsBitArray];
    BitArray *_lastAddress = [self calculateLastAddress];
    BitArray *_firstAddress = [self calculateFirstAddress];
    
    return ([_ipAddress greaterThanOrEqualToBitArray:_firstAddress] && [_ipAddress lessThanOrEqualToBitArray:_lastAddress]);
}



/**
 Returns IPv6 Array with values from shorthanded IPv6 filled in.
 e.g. ffe12d::1 -> ffe12d:0000:0000:0000:0000:0000:0000:1
 **/

//method might need some fixing
- (NSArray *)fillIPv6Address:(NSString *)ipAddrString
{
    NSMutableArray *sectionsArray = [[NSMutableArray alloc] init];
    NSArray *ipAddrArray;
    int numberOfSections = 0;
    
    if ([ipAddrString rangeOfString:@"::"].location != NSNotFound)
    {
        ipAddrArray = [ipAddrString componentsSeparatedByString:@":"];
        
        for (int i = 0; i < [ipAddrArray count]; i++)
        {
            if ([[ipAddrArray objectAtIndex:i] isEqual:@""])
            {
                numberOfSections++;
                [sectionsArray addObject:@"0000"];
            }
        }
        
        [ipAddrString stringByReplacingOccurrencesOfString:@"::"
                                                withString:[NSString stringWithFormat:@"%@", [sectionsArray componentsJoinedByString:@":"]]];
        [ipAddrString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
    }
    
    return [ipAddrString componentsSeparatedByString:@":"];
}



@end
