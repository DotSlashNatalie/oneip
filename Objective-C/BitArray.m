//
//  BitArray.m
//  oneIP
//
//  Created by Bret Deasy on 7/16/13.
//  Copyright (c) 2013 Bret Deasy. All rights reserved.
//

#import "BitArray.h"

@implementation BitArray

@synthesize bitVector;

/**
 Initialize with empty bitVector
 **/
- (id)init
{
    self = [super init];
    
    if (self)
    {
        bitVector = CFBitVectorCreateMutable(kCFAllocatorDefault, 0);
    }
    
    return self;
}

/**
 Returns a BitArray object initialized by copying the bits from another given BitArray.
 **/
- (id)initWithBitArray:(BitArray *)bitArray
{
    return [self initWithBitVector:[bitArray bitVector]];
}

/**
 Initialize with capacity-sized bitVector containing all zeroes.
 **/
- (id)initWithCount:(CFIndex)count
{
    self = [super init];
    
    if (self)
    {
        bitVector = CFBitVectorCreateMutable(kCFAllocatorDefault, 0);
        [self setCount:count];
    }
    
    return self;
}

/**
 Initializer from a given string of 0s and/or 1s.
 */
- (id)initWithString:(NSString *)bitString
{
    self = [super init];
    
    if (self)
    {
        int length = [bitString length];
        CFMutableBitVectorRef _bitVector = CFBitVectorCreateMutable(kCFAllocatorDefault, length);
        CFBitVectorSetCount(_bitVector, length);
        
        for (int i = 0; i < length; i++)
        {
            int bitAtIndex = [bitString characterAtIndex:i] - 48;
            CFBitVectorSetBitAtIndex(_bitVector, i, bitAtIndex);
        }
        
        bitVector = CFBitVectorCreateMutableCopy(kCFAllocatorDefault, length, _bitVector);
        
        CFRelease(_bitVector);
    }
    
    return self;
}

/**
 Initializer from a given CFBitVectorRef.
 */
- (id)initWithBitVector:(CFMutableBitVectorRef)_bitVector
{
    self = [super init];
    
    if (self)
    {
        bitVector = CFBitVectorCreateMutableCopy(kCFAllocatorDefault, CFBitVectorGetCount(_bitVector), _bitVector);
    }
    
    return self;
}

/**
 Initialize from a given Int. Integer must be 0 or greater.
 **/
- (id)initWithInteger:(int)value
{
    self = [super init];
    
    if (self)
    {
        int capacity;
        
        if (value <= 0)
        {
            bitVector = CFBitVectorCreateMutable(kCFAllocatorDefault, 1);
            CFBitVectorSetCount(bitVector, 1);
        } else {
            capacity = floor(log2(value))+1;
            bitVector = CFBitVectorCreateMutable(kCFAllocatorDefault, capacity);
            CFBitVectorSetCount(bitVector, capacity);

            for (int i = capacity - 1; i >= 0; i--)
            {
                CFBitVectorSetBitAtIndex(bitVector, i, (value & 1));
                value>>=1;
            }
        }
    }
    
    return self;
}

/**
 Returns the AND of the receiver's bitVector and the passed BitArray's bitVector.
 */
- (BitArray *)bitArrayByANDingWithBitArray:(BitArray *)andBitArray
{
    CFBit aBit;
    CFBit bBit;
    CFBit resultBit;
    
    [self equalizeBitVector:andBitArray];
    int capacity = [self count];
    CFMutableBitVectorRef resultBitArray = CFBitVectorCreateMutable(kCFAllocatorDefault, capacity);
    CFBitVectorSetCount(resultBitArray, capacity);
    
    for (int i = 0; i < capacity; i++)
    {
        aBit = CFBitVectorGetBitAtIndex(bitVector, i);
        bBit = CFBitVectorGetBitAtIndex([andBitArray bitVector], i);
        
        resultBit = aBit & bBit;
        CFBitVectorSetBitAtIndex(resultBitArray, i, resultBit);
    }
    
    BitArray *retBitArray = [[BitArray alloc] initWithBitVector:resultBitArray];
    CFRelease(resultBitArray);
    
    return retBitArray;
    
}

/**
 Returns the OR of the receiver's bitVector with the passed BitArray's bitVector.
 **/
- (BitArray *)bitArrayByORingWithBitArray:(BitArray *)orBitArray
{
    CFBit aBit;
    CFBit bBit;
    CFBit resultBit;
    
    [self equalizeBitVector:orBitArray];
    int capacity = [self count];
    
    CFMutableBitVectorRef resultBitArray = CFBitVectorCreateMutable(kCFAllocatorDefault, capacity);
    CFBitVectorSetCount(resultBitArray, capacity);
    
    for (int i = 0; i < capacity; i++)
    {
        aBit = CFBitVectorGetBitAtIndex(bitVector, i);
        bBit = CFBitVectorGetBitAtIndex([orBitArray bitVector], i);
        
        resultBit = aBit | bBit;
        CFBitVectorSetBitAtIndex(resultBitArray, i, resultBit);
    }
    
    BitArray *retBitArray = [[BitArray alloc] initWithBitVector:resultBitArray];
    CFRelease(resultBitArray);
    
    return retBitArray;
}

/**
 Returns the NOT of the receiver's bitVector.
 **/
- (BitArray *)bitArrayByNOTingBitArray
{
    CFBit bit;
    CFBit resultBit;
    
    int capacity = [self count];
    
    CFMutableBitVectorRef resultBitArray = CFBitVectorCreateMutable(kCFAllocatorDefault, capacity);
    CFBitVectorSetCount(resultBitArray, capacity);
    
    for (int i = 0; i < capacity; i++)
    {
        bit = CFBitVectorGetBitAtIndex(bitVector, i);
        resultBit = !bit;
        
        CFBitVectorSetBitAtIndex(resultBitArray, i, resultBit);
    }
    
    BitArray *retBitArray = [[BitArray alloc] initWithBitVector:resultBitArray];
    CFRelease(resultBitArray);
    
    return retBitArray;
}

/**
 Returns the number of bits in the receiver's bitVector.
 **/
- (int)count
{
    return CFBitVectorGetCount(bitVector);
}

/**
 Sets the size of the receiver's bitVector
 **/
- (void)setCount:(CFIndex)count
{
    CFBitVectorSetCount(bitVector, count);
}
/**
 Makes the receiver's bitVector and the parameter's of equal size
 **/
- (void)equalizeBitVector:(BitArray *)bitArray
{
    int bitVectorCapacity = [self count];
    int compareBitVectorCapacity = [bitArray count];
    
    if (bitVectorCapacity < compareBitVectorCapacity)
    {
        [self padToCapacity:compareBitVectorCapacity];
    } else if (bitVectorCapacity > compareBitVectorCapacity) {
        [bitArray padToCapacity:bitVectorCapacity];
    }
}

/**
 Pads 0s to the left to make the bitVector's capacity match the parameter.
 */
- (void)padToCapacity:(int)capacity
{
    int difference = capacity - [self count];
    
    if (difference <= 0)
    {
        return;
    }
    
    
    CFMutableBitVectorRef tempVector = CFBitVectorCreateMutable(kCFAllocatorDefault, difference);
    CFBitVectorSetCount(tempVector, difference);

    BitArray *insertBitArray = [[BitArray alloc] initWithBitVector:tempVector];

    [self insertBitArray:insertBitArray atIndex:0];
//    for (int i = difference; i < capacity; difference++)
//    {
//        CFBitVectorSetBitAtIndex(tempVector, i, CFBitVectorGetBitAtIndex(bitVector, currIndex));
//        currIndex++;
//    }
//    
//    bitVector = CFBitVectorCreateMutableCopy(kCFAllocatorDefault, capacity, tempVector);
//    CFRelease(tempVector);
}

/**
 Returns a new BitArray made by appending a given BitArray to the receiver.
 **/
- (BitArray *)bitArrayByAppendingBitArray:(BitArray *)bitArray
{
//     return [[[BitArray alloc] initWithBitArray:self] bitArrayByAppendingBitArray:bitArray];
    BitArray *retBitArray = [[BitArray alloc] initWithBitArray:self];
    [retBitArray insertBitArray:bitArray atIndex:[self count]];
    
    return retBitArray;
}

/**
 Returns BitArray containing the bitVector of the value parameter added to the receiver's bitVector.
 **/
- (BitArray *)bitArrayByAddingInteger:(int)value
{
    return [self performMathOperation:Add withInt:value];
}

/**
 Returns BitArray containing the bitVector of the value parameter subtracted from the receiver's bitVector.
 **/
- (BitArray *)bitArrayBySubtractingInteger:(int)value
{
    return [self performMathOperation:Subtract withInt:value];
}

/**
 Returns BitArray represented after performing the selected math operation with the given value on the receiver.
 **/
- (BitArray *)performMathOperation:(Operation)op withInt:(int)value
{
    int capacity = [self count];
    
    CFMutableBitVectorRef bits = CFBitVectorCreateMutable(kCFAllocatorDefault, capacity);
    CFBitVectorSetCount(bits, capacity);
    
    CFMutableBitVectorRef result = CFBitVectorCreateMutable(kCFAllocatorDefault, 2);
    CFBitVectorSetCount(result, 2);
    
    BitArray *valueBitArray = [[BitArray alloc] initWithInteger:value];
    [self equalizeBitVector:valueBitArray];
    
    for (int i = capacity - 1; i >= 0; i--)
    {
        int aBit = CFBitVectorGetBitAtIndex(bitVector, i);
        int bBit = CFBitVectorGetBitAtIndex([valueBitArray bitVector], i);
        int cBit = CFBitVectorGetBitAtIndex(result, 1);
        
        if (op == Add)
        {
            result = [self fullAdderWithaBit:aBit
                                        bBit:bBit
                                        cBit:cBit];
        } else if (op == Subtract) {
            result = [self fullSubtractorWithaBit:aBit
                                             bBit:bBit
                                             cBit:cBit];
        }
        
        CFBitVectorSetBitAtIndex(bits, i, CFBitVectorGetBitAtIndex(result, 0));
    }
    
    BitArray *retBitArray = [[BitArray alloc] initWithBitVector:bits];
    CFRelease(result);
    CFRelease(bits);
    
    return retBitArray;
}

/**
 Returns the sum bit and carry bit after performing an addition operation.
 **/
- (CFMutableBitVectorRef)fullAdderWithaBit:(BOOL)aBit bBit:(BOOL)bBit cBit:(BOOL)cBit
{
    //bit0 = sum bit
    //bit1 = carry bit
    BOOL bit0 = (aBit ^ bBit) ^ cBit;
    BOOL bit1 = (aBit & bBit) | (bBit & cBit) | (aBit & cBit);
    
    CFMutableBitVectorRef retBitVector = CFBitVectorCreateMutable(kCFAllocatorDefault, 2);
    CFBitVectorSetCount(retBitVector, 2);
    CFBitVectorSetBitAtIndex(retBitVector, 0, bit0);
    CFBitVectorSetBitAtIndex(retBitVector, 1, bit1);
    
    return retBitVector;
}

/**
 Returns the sum bit and carry bit after performing an subtraction operation.
 **/
- (CFMutableBitVectorRef)fullSubtractorWithaBit:(BOOL)aBit bBit:(BOOL)bBit cBit:(BOOL)cBit
{
    //bit0 = sum bit
    //bit1 = carry bit
    BOOL bit0 = aBit ^ bBit ^ cBit;
    BOOL bit1 = (cBit & (aBit ^ bBit)) | (!aBit & bBit);
    
    CFMutableBitVectorRef retBitVector = CFBitVectorCreateMutable(kCFAllocatorDefault, 2);
    CFBitVectorSetCount(retBitVector, 2);
    CFBitVectorSetBitAtIndex(retBitVector, 0, bit0);
    CFBitVectorSetBitAtIndex(retBitVector, 1, bit1);
    
    return retBitVector;
}

/**
 Returns true if the receiver's bitVector is equal to that of the parameter's.
 **/
- (BOOL)equalToBitArray:(BitArray *)bitArray
{
    CFBit bit;
    CFBit bitCompare;
    
    for (int i = 0; i < [self count]; i++)
    {
        bit = CFBitVectorGetBitAtIndex(bitVector, i);
        bitCompare = CFBitVectorGetBitAtIndex([bitArray bitVector], i);
        
        if (bit != bitCompare)
        {
            return NO;
        }
    }
    
    return YES;
}


/**
 Returns true if the receiver's bitVector is greater than or equal to that of the parameter's.
 **/
- (BOOL)greaterThanOrEqualToBitArray:(BitArray *)bitArray
{
    return ([self greaterThanBitArray:bitArray] || [self equalToBitArray:bitArray]);
}

/**
 Returns true if the receiver's bitVector is less than or equal to that of the parameter's.
 **/
- (BOOL)lessThanOrEqualToBitArray:(BitArray *)bitArray
{
    return ([self lessThanBitArray:bitArray] || [self equalToBitArray:bitArray]);
}

/**
 Returns true if the receiver's bitVector is greater than that of the parameter.
 **/
- (BOOL)greaterThanBitArray:(BitArray *)bitArray
{
    [self equalizeBitVector:bitArray];

    CFBit bit;
    CFBit compareBit;
    
    for (int i = [self count] - 1; i >= 0; i--)
    {
        bit = [self bitAtIndex:i];
        compareBit = [bitArray bitAtIndex:i];
        
        if (bit > compareBit)
        {
            return YES;
        } else if (bit < compareBit) {
            return NO;
        }
    }
    
    return NO;
}

/**
 Returns true of the receiver's bitVector is less than that of the parameter's
 **/
- (BOOL)lessThanBitArray:(BitArray *)bitArray
{
    [self equalizeBitVector:bitArray];
    
    CFBit bit;
    CFBit compareBit;
    
    for (int i = [self count]; i > 0; i--)
    {
        bit = [self bitAtIndex:i];
        compareBit = [bitArray bitAtIndex:i];
        
        if (bit < compareBit)
        {
            return YES;
        } else if (bit > compareBit) {
            return NO;
        }
    }
    
    return NO;
}

/**
 Returns the bit from the receiver's bitVector at the given index.
 **/
- (CFBit)bitAtIndex:(CFIndex)index
{
    return CFBitVectorGetBitAtIndex(bitVector, index);
}

/**
 Sets the bit of the receiver's bitVector at the given index to the given value.
 **/
- (void)setBitAtIndex:(CFIndex)index toValue:(CFBit)bit
{
    CFBitVectorSetBitAtIndex(bitVector, index, bit);
}

/**
 Inserts the given bitArray into the receiver at the given index. Receiver will expand as needed.
 **/
- (void)insertBitArray:(BitArray *)bitArray atIndex:(CFIndex)index
{
    int count = [self count];
    int newCount = count + [bitArray count];
    int difference = [bitArray count];
    int currIndex = 0;
    
    [self setCount:newCount];
    
    for (int i = count-1; i >= index; i--)
    {
        [self setBitAtIndex:i+difference toValue:[self bitAtIndex:i]];
    }
    
    for (int i = index; i < index+difference; i++)
    {
        [self setBitAtIndex:i toValue:[bitArray bitAtIndex:currIndex]];
        currIndex++;
    }
//    if ([bitArray count] + index >= [self count])
//    {
//        [self setCount:[bitArray count] + index + 1];
//    }
//    for (int i = 0; i < [bitArray count]; i++)
//    {
//        CFBitVectorSetBitAtIndex(bitVector, index+i, [bitArray bitAtIndex:i]);
//    }
}

/**
 Returns the int value of the bits in the given range of the receiver's bitVector.
 **/
- (int)bitsInRange:(CFRange)range
{
    int quotient = floor(range.length / 8);
    Byte *bytes = malloc(sizeof(Byte) * quotient);
    unsigned int byteValue = 0;
    
    CFBitVectorGetBits(bitVector, range, bytes);
    memcpy(&byteValue, bytes, quotient);
    //ensure big-endianness
    if (quotient > 1)
    {
        byteValue = htons(byteValue);
    }

    return byteValue;
}

/**
 Returns the string representation of the receiver.
 **/
- (NSString *)stringValue
{
    NSString *retString = @"";
    
    for (int i = 0; i < [self count]; i++)
    {
        retString = [retString stringByAppendingFormat:@"%ld", [self bitAtIndex:i]];
    }
    
    return  retString;
}

-(void)dealloc
{
    CFRelease(bitVector);
}

@end
