# BitArray by Nathan Adams

import operator

class BitArray:
    #I couldn't get BitArray from the Python site to compile
    #so I don't want other people tearing their hair out trying to do the same
    #let us create our own
    class BitArrayBooleanOperations:
        AND = 0
        OR = 1
        XOR = 2
    class BitArrayMathOperations:
        ADD = 0
        SUBTRACT = 1
    __barray = []
    LITTLE_ENDIAN = 0
    BIG_ENDIAN = 1
    __endian = None
    def __init__(self, size=0, bitarray=None, endian=LITTLE_ENDIAN):
        self.__endian = endian
        if bitarray == None:
            self.__barray = [False for i in  self._lrange(0, size)]
        elif type(bitarray) == type([]):
            self.__barray = bitarray[:]
        elif type(bitarray) == type(BitArray()):
            if bitarray.size() < size:
                self.__barray = [False for i in self._lrange(0, size - bitarray.size())] + bitarray.getRawArray()[:]
            else:
                self.__barray = bitarray.getRawArray()[:]

    def __strEndian(self, end):
        if end == 0:
            print "Little Endian"
        elif end == 1:
            print "Big Endian"

    def _lrange(self, num1, num2 = None, step = 1):
        op = operator.__lt__

        if num2 is None:
            num1, num2 = 0, num1
        if num2 < num1:
            if step > 0:
                num1 = num2
            op = operator.__gt__
        elif step < 0:
            num1 = num2

        while op(num1, num2):
            yield num1
            num1 += step
    
    def __str__(self):
        if self.__endian == 1:
            return "".join([str(int(i)) for i in self.__barray])
        else:
            return "".join([str(int(i)) for i in reversed(self.__barray)])

    def __invert__(self):
        retarr = [(not i) for i in self.__barray]
        #print retarr
        #retarr.reverse()
        #print retarr
        return BitArray(bitarray=retarr)

    def __len__(self):
        return len(self.__barray)

    def size(self):
        return self.__len__()

    def __and__(self, b2):
        return self.__booloperation(b2, self.BitArrayBooleanOperations.AND)
    
    def __booloperation(self, b2, operation):
        if type(b2) == type(BitArray()):
            if self.__endian != b2.getEndian():
                print "WARNING: Endians do not match - are you sure this is what you want?"
            if self.size() == b2.size():
                if operation == self.BitArrayBooleanOperations.AND:
                    return self._and(self, b2)
                elif operation == self.BitArrayBooleanOperations.OR:
                    return self._or(self, b2)
                elif operation == self.BitArrayBooleanOperations.XOR:
                    return self._xor(self, b2)
            elif self.size() > b2.size():
                if operation == self.BitArrayBooleanOperations.AND:
                    return self._and(self, BitArray(size=self.size(),bitarray=b2,endian=b2.getEndian()))
                elif operation == self.BitArrayBooleanOperations.OR:
                    return self._or(self, BitArray(size=self.size(),bitarray=b2,endian=b2.getEndian()))
                elif operation == self.BitArrayBooleanOperations.XOR:
                    return self._xor(self, BitArray(size=self.size(),bitarray=b2,endian=b2.getEndian()))
            else:
                if operation == self.BitArrayBooleanOperations.AND:
                    return self._and(BitArray(size=b2.size(),bitarray=self,endian=self.getEndian()),b2)
                elif operation == self.BitArrayBooleanOperations.OR:
                    return self._or(BitArray(size=b2.size(),bitarray=self,endian=self.getEndian()),b2)
                elif operation == self.BitArrayBooleanOperations.XOR:
                    return self._xor(BitArray(size=b2.size(),bitarray=self,endian=self.getEndian()),b2)
        else:
            return None
    
    def __xor__(self, b2):
        return self.__booloperation(b2, self.BitArrayBooleanOperations.XOR)

    def _xor(self, ba1, ba2):
        return BitArray(bitarray=[ba1[i] ^ ba2[i] for i in self._lrange(0, len(ba1))])

    def __or__(self, b2):
        return self.__booloperation(b2, self.BitArrayBooleanOperations.OR)

    def _or(self, ba1, ba2):
        return BitArray(bitarray=[ba1[i] | ba2[i] for i in self._lrange(0, len(ba1))])

    def _and(self, ba1, ba2):
        return BitArray(bitarray=[ba1[i] & ba2[i] for i in self._lrange(0, len(ba1))])

    def getRawArray(self):
        return self.__barray

    def __getitem__(self, index):
        return self.__barray[index]

    def __getslice__(self, low, high):
        return self.__barray[low:high]

    def __setitem__(self, index, value):
        if type(value) == type(True):
            if self.__endian == BitArray.LITTLE_ENDIAN:
                self.__barray[(len(self)-index)-1] = value
            elif self.__endian == BitArray.BIG_ENDIAN:
                self.__barray[index] = value

    def getEndian(self):
        return self.__endian

    def __eq__(self, b2):
        if b2:
            return self.__barray == b2.getRawArray()
        else:
            return False

    def __ne__(self, b2):
        return not self.__eq__(b2)

    def __lt__(self, b2):
        #Idea from -> http://mailman.linuxchix.org/pipermail/courses/2002-November/001043.html
        #
        # true if bi1 < bi2
        # false if bi1 > bi2
        # need to create resizing function
        #if self != b2
        if self == b2:
            return False
        if self.__BitArrayCompare(b2):
            return False
        else:
            return True

    def __gt__(self, b2):
        if self == b2:
            return False
        return not self.__lt__(b2)

    def __ge__(self, b2):
        if self == b2:
            return True
        return self.__gt__(b2)

    def __le__(self, b2):
        if self == b2:
            return True
        return self.__le__(b2)

    def __BitArrayMathControl(self, val, operation):
        bits = [False for i in range(0, len(self))]
        result = [False, False]
        valboolarr = [False for i in range(0, len(self))]

        if self.__endian == 0:
            tmpboolarr = [bool(int(i)) for i in bin(val)[2:].rjust(len(self), '0')]
        elif self.__endian == 1:
            tmpboolarr = [bool(int(i)) for i in bin(val)[2:].ljust(len(self), '0')]

        valbits = []
        bval = BitArray(bitarray=valboolarr)

        if self.__endian == 0:
            for i in range(0, len(tmpboolarr)-1):
                valboolarr[len(self) - 1 - i] = tmpboolarr[len(tmpboolarr) - i - 1]
        elif self.__endian == 1:
            for i in range(len(self)-1, 0, -1):
                valboolarr[i] = tmpboolarr[i]

        for i in range(0, len(self)):
            if operation == self.BitArrayMathOperations.ADD:
                result = self.__fullAdder(self[i], valboolarr[i], result[1])
            elif operation == self.BitArrayMathOperations.SUBTRACT:
                result = self.__fullSubtractor(self[i], valboolarr[i], result[1])
            bits[i] = result[0]

        if result[1]: # was there a carry over? return a resized array
            bits.append(True)
        if self.__endian == self.BIG_ENDIAN:
            bits.reverse()
        return BitArray(bitarray=bits)

    def __fullAdder(self, abit, bbit, cbit):
        ret = [False, False]
        ret[0] = (abit ^ bbit) ^ cbit
        ret[1] = (abit & bbit) | (bbit & cbit) | (abit & cbit)
        return ret

    def __fullSubtractor(self, abit, bbit, cbit):
        ret = [False, False]
        ret[0] = abit ^ bbit ^ cbit
        ret[1] = cbit & (abit ^ bbit) | (not abit) & bbit
        return ret

    def __add__(self, val):
        return self.__BitArrayMathControl(val, BitArray.BitArrayMathOperations.ADD)

    def __sub__(self, val):
        return self.__BitArrayMathControl(val, BitArray.BitArrayMathOperations.SUBTRACT)

    def __BitArrayCompare(self, b2):
        # true if bi1 < bi2
        # false if bi1 > bi2
        if len(self) == len(b2):
            if self.__endian != b2.getEndian():
                print "Endians do NOT match - is this what you want? Assuming Endian " + self.__strEndian(self.__endian)
            if self.__endian == 0:
                for i in range(len(self)-1, 0, -1):
                    if self[i] == True and b2[i] != True:
                        return False
                    if self[i] != True and b2[i] == False:
                        return True
                return False
            elif self.__endian == 1:
                for i in range(0, len(self)):
                    if self[i] == True and b2[i] != True:
                        return False
                    if self[i] != True and b2[i] == False:
                        return True
                return False
        else:
            raise Exception("Bitsize is not the same")
