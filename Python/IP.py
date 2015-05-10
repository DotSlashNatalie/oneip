from BitArray import BitArray

class InvalidIPFormat(Exception):
    def __init__(self, value):
        self.val = value
    def __str__(self):
        return "The input " + str(self.val) + " was not a valid IP address in the proper format"

class InvalidIP(Exception):
    def __init__(self, value, type):
        self.val = value
        self.type = type
    def __str__(self):
        return "The input " + str(self.val) + " was not a valid IPv" + str(self.type) + " address in the proper format"

class InvalidIPInput(Exception):
    def __init__(self, value, einput):
        self.val = value
        self.einput = einput
    def __str__(self):
        return "The input " + str(self.val) + " was not an expected object - expected " + str(einput)

class InvalidMask(Exception):
    def __init__(self):
        pass
    def __str__(self):
        return "The subnet mask has not been set"

class IPNotSet(Exception):
    def __init__(self):
        pass
    def __str__(self):
        return "The IP address has not been set"

class IP:
    __cidr = None
    __ipaddr = None
    __type = None
    def __init__(self, ipaddr):
        if self.setIPv4(ipaddr):
            return
        elif self.setIPv6(ipaddr):
            return
        else:
            raise InvalidIPFormat(ipaddr)
            #print "
    
    def setIPv4(self, ip):
        # IP format is in CIDR notiation - 192.168.128.0/16

        iparr = []
        ipcidrarr = []
        cidr = None
        if ":" in ip:
            return False
        if type(ip) != type(str()):
            raise InvalidIPInput(ip, "string")
        if "/" in ip:
            ipcidrarr = ip.split("/")
            if not self.__isValidIPv4(ipcidrarr[0]):
                raise InvalidIP(ip, 4)
            iparr = ipcidrarr[0].split(".")
            self.__cidr = self.__getCIDR(int(ipcidrarr[1]), 32)
        else:
            if not self.isValidIPv4(ip):
                raise InvalidIP(ip, 4)
            iparr = ip.split(".")            
        if len(iparr) != 4:
            raise Exception("Not enough octects")
        
        else:
            self.__ipaddr = self.__IPv4ToBin(iparr)
            self.__type = 4
        return True 

    def setIPv6(self, ip):
        if "/" in ip:
            ipv6 = ip.split("/")
            self.__cidr = self.__getCIDR(int(ipv6[1]), 128)
            ipv6arr = ipv6[0].split(":")
        else:
            ipv6arr = ip.split(":")
        newipaddr = self.__fillIPv6Address(":".join(ipv6arr))
        if not self.__isValidIPv6(":".join(newipaddr)):
            raise InvalidIP(ip, 6)
        self.__ipaddr = self.__IPv6ToBin(newipaddr)
        self.__type = 6
        return True


    def __IPv4ToBin(self, iparr):
        octarr = []
        octarr = self.__toBinary(int(iparr[0]), 8)
        octarr.extend(self.__toBinary(int(iparr[1]), 8))
        octarr.extend(self.__toBinary(int(iparr[2]), 8))
        octarr.extend(self.__toBinary(int(iparr[3]), 8))
        return BitArray(bitarray=octarr)

    def __IPv6ToBin(self, iparr):
        octarr = []
        octarr = self.__toBinary(int(iparr[0], 16), 16)
        octarr.extend(self.__toBinary(int(iparr[1], 16), 16))
        octarr.extend(self.__toBinary(int(iparr[2], 16), 16))
        octarr.extend(self.__toBinary(int(iparr[3], 16), 16))
        octarr.extend(self.__toBinary(int(iparr[4], 16), 16))
        octarr.extend(self.__toBinary(int(iparr[5], 16), 16))
        octarr.extend(self.__toBinary(int(iparr[6], 16), 16))
        octarr.extend(self.__toBinary(int(iparr[7], 16), 16))
        return BitArray(bitarray=octarr)

    def __isValidIPv4(self, ipaddr):
        try:
            iparr = ipaddr.split(".")
            oct1 = int(iparr[0])
            oct2 = int(iparr[1])
            oct3 = int(iparr[2])
            oct4 = int(iparr[3])
        except Exception, e:
            raise Exception("There was a problem converting the octects to ints", e)

        if oct1 <= 0 and oct1 >= 255:
            return False
        if oct2 <= 0 and oct2 >= 255:
            return False
        if oct3 <= 0 and oct3 >= 255:
            return False
        if oct4 <= 0 and oct4 >= 255:
            return False
        return True

    def __isValidIPv6(self, ipaddr):
        try:
            iparr = ipaddr.split(":")
            oct1 = int(iparr[0])
            oct2 = int(iparr[1])
            oct3 = int(iparr[2])
            oct4 = int(iparr[3])
            oct5 = int(iparr[4])
            oct6 = int(iparr[5])
            oct7 = int(iparr[6])
            oct8 = int(iparr[7])
        except Exception, e:
            raise Exception("There was a problem converting the octects to ints", e)

        if oct1 <= 0 and oct1 >= 0xFFFF:
            return False
        if oct2 <= 0 and oct2 >= 0xFFFF:
            return False
        if oct3 <= 0 and oct3 >= 0xFFFF:
            return False
        if oct4 <= 0 and oct4 >= 0xFFFF:
            return False
        if oct5 <= 0 and oct5 >= 0xFFFF:
            return False
        if oct6 <= 0 and oct6 >= 0xFFFF:
            return False
        if oct7 <= 0 and oct7 >= 0xFFFF:
            return False
        if oct8 <= 0 and oct8 >= 0xFFFF:
            return False
        return True

    def __toBinary(self, oct, pad):
        biarr = []
        binary = bin(oct)[2:]
        binary = binary.rjust(pad, '0')
        for c in binary:
            if c == '0':
                biarr.append(False)
            elif c == '1':
                biarr.append(True)
        return biarr

    def __getCIDR(self, cidr, numofbits):
        cidrbits = []
        for i in range(0, cidr):
            cidrbits.append(True)
        if len(cidrbits) < numofbits:
            for i in range(0, numofbits - cidr):
                cidrbits.append(False)
        return BitArray(bitarray=cidrbits)

    def __fillIPv6Address(self, ipstr):
        sections = []
        ipv6arr = []
        if "::" in ipstr:
            ipv6arr = ipstr.split(":")
            numofsections = 8 - len([x for x in ipv6arr if x != ""])
            for i in range(0, numofsections):
                sections.append("0000")
            tmpip = ipstr.replace("::", ":" + ":".join(sections) + ":")
            return tmpip.strip(":").split(":")
        else:
            return ipstr.split(":")

    def __calcIPv4Address(self, bitarr):
        oct1 = self.__bitsToDec(bitarr[0:8])
        oct2 = self.__bitsToDec(bitarr[8:16])
        oct3 = self.__bitsToDec(bitarr[16:24])
        oct4 = self.__bitsToDec(bitarr[24:32])
        return "%s.%s.%s.%s" % (oct1, oct2, oct3, oct4)

    def __calcIPv6Address(self, bitarr):
        oct1 = self.__bitsToHex(bitarr[0:16])
        oct2 = self.__bitsToHex(bitarr[16:32])
        oct3 = self.__bitsToHex(bitarr[32:48])
        oct4 = self.__bitsToHex(bitarr[48:64])
        oct5 = self.__bitsToHex(bitarr[64:80])
        oct6 = self.__bitsToHex(bitarr[80:96])
        oct7 = self.__bitsToHex(bitarr[96:112])
        oct8 = self.__bitsToHex(bitarr[112:128])
        return "%s:%s:%s:%s:%s:%s:%s:%s" % (oct1, oct2, oct3, oct4, oct5, oct6, oct7, oct8)
    
    def __bitsToDec(self, bitarr):
        bitstr = "".join([str(x) for x in bitarr])
        bitstr = bitstr.replace("True", "1")
        bitstr = bitstr.replace("False", "0")
        return int(bitstr, 2)
         
    def __bitsToHex(self, bitarr):
        return hex(self.__bitsToDec(bitarr))[2:].upper()

    def getIPv4SubnetMask(self):
        if self.__type == 4:
            return self.__calcIPv4Address(self.__cidr)
        else:
            return ""

    def getIPv4Address(self):
        return self.__calcIPv4Address(self.__ipaddr)

    def __calcIPv4FirstAddress(self):
        # print str(self.__ipaddr)
        return (self.__ipaddr & self.__cidr) + 1

    def __calcIPv4LastAddress(self):
        return (self.__ipaddr | ~self.__cidr) - 1

    def __calcIPv4NetworkAddress(self):
        return (self.__ipaddr & self.__cidr)

    def __calcIPv4BroadcastAddress(self):
        return (self.__ipaddr | ~self.__cidr)

    def getIPv4FirstAddress(self):
        return self.__calcIPv4Address(self.__calcIPv4FirstAddress())

    def getIPv4LastAddress(self):
        return self.__calcIPv4Address(self.__calcIPv4LastAddress())

    def getIPv4NetworkAddress(self):
        return self.__calcIPv4Address(self.__calcIPv4NetworkAddress())

    def getIPv4BroadcastAddress(self):
        return self.__calcIPv4Address(self.__calcIPv4BroadcastAddress())

    def getIPv6Address(self):
        return self.__calcIPv6Address(self.__ipaddr)

    def __calcIPv6FirstAddress(self):
        return (self.__ipaddr & self.__cidr) + 1

    def getIPv6FirstAddress(self):
        return self.__calcIPv6Address(self.__calcIPv6FirstAddress())

    def __calcIPv6LastAddress(self):
        return (self.__ipaddr | ~self.__cidr) - 1

    def getIPv6LastAddress(self):
        return self.__calcIPv6Address(self.__calcIPv6LastAddress())

    def isIPv4AddressinRange(self, ip):
        if "." in ip and self.isValidIPv4(ip):
            inputip = self.__IPv4ToBin(ip.split("."))
            firstip = self.__calcIPv4FirstAddress()
            lastip = self.__calcIPv4LastAddress()
            if inputip >= firstip and inputip <= lastip:
                return True
            else:
                return False
        else:
            return False

    def getIPv6Range(self):
        currip = self.__calcIPv6FirstAddress()
        lastip = self.__calcIPv6LastAddress()
        ipaddrs = []
        while(currip != lastip):
            ipaddrs.append(self.__calcIPv6Address(currip))
            currip = currip + 1
        ipaddrs.append(self.__calcIPv6Address(currip))
        return ipaddrs

    def getIPv4Range(self):
        currip = self.__calcIPv4FirstAddress()
        lastip = self.__calcIPv4LastAddress()
        ipaddrs = []
        while(currip != lastip):
            ipaddrs.append(self.__calcIPv4Address(currip))
            currip = currip + 1
        ipaddrs.append(self.__calcIPv4Address(currip))
        return ipaddrs

    def isIPv6AddressinRange(self, ip):
        if ":" in ip and self.__isValidIPv6(ip.split(":")):
            inputip = self.__IPv6ToBin(ip)
            firstip = self.__calcIPv6FirstAddress()
            lastip = self.__calcIPv6LastAddress()
            if inputip >= firstip and inputip <= lastip:
                return True
            else:
                return False
        else:
            return False