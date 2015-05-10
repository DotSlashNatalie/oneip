//
//  BitArray.h
//  oneIP
//
//  Created by Bret Deasy on 7/16/13.
//  Copyright (c) 2013 Bret Deasy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    Add,
    Subtract
} Operation;

typedef enum {
    Lesser,
    Greater,
    Equal
} Comparison;

@interface BitArray : NSObject

@property (nonatomic) CFMutableBitVectorRef bitVector;


- (id)init;
- (id)initWithString:(NSString *)bitString;
- (id)initWithBitVector:(CFMutableBitVectorRef)_bitVector;
- (id)initWithInteger:(int)value;
- (id)initWithCount:(CFIndex)count;
- (id)initWithBitArray:(BitArray *)bitArray;
- (BitArray *)bitArrayByANDingWithBitArray:(BitArray *)andBitArray;
- (BitArray *)bitArrayByORingWithBitArray:(BitArray *)orBitArray;
- (BitArray *)bitArrayByNOTingBitArray;
- (int)count;
- (void)setCount:(CFIndex)count;
- (void)equalizeBitVector:(BitArray *)bitArray;
- (void)padToCapacity:(int)capacity;
- (BitArray *)bitArrayByAppendingBitArray:(BitArray *)bitArray;
- (BitArray *)bitArrayByAddingInteger:(int)value;
- (BitArray *)bitArrayBySubtractingInteger:(int)value;
- (BitArray *)performMathOperation:(Operation)op withInt:(int)value;
- (BOOL)equalToBitArray:(BitArray *)bitArray;
- (BOOL)greaterThanOrEqualToBitArray:(BitArray *)bitArray;
- (BOOL)lessThanOrEqualToBitArray:(BitArray *)bitArray;
- (BOOL)greaterThanBitArray:(BitArray *)bitArray;
- (BOOL)lessThanBitArray:(BitArray *)bitArray;
- (CFBit)bitAtIndex:(CFIndex)index;
- (int)bitsInRange:(CFRange)range;
- (void)setBitAtIndex:(CFIndex)index toValue:(CFBit)bit;
- (void)insertBitArray:(BitArray *)bitArray atIndex:(CFIndex)index;
- (NSString *)stringValue;

@end
