//
//  OIPUtility.m
//  oneIP
//
//  Created by Bret Deasy on 7/17/13.
//  Copyright (c) 2013 Bret Deasy. All rights reserved.
//

#import "OIPUtility.h"

@implementation OIPUtility

/**
 Returns a string representing the decimal value of the hex string parameter.
 **/
+ (int)hexStringToDecimal:(NSString *)hexString
{
    unsigned result = 0;
    NSScanner *scanner;
    scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:0];
    [scanner scanHexInt:&result];
    
    return result;
}


@end
