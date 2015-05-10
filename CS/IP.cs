using System;
using System.Collections.Generic;
using System.Collections;
using System.Linq;
using System.Text;
using System.Runtime.Serialization;

namespace Network
{

    public static class Int32Extensions
    {
        public static Boolean[] ToBooleanArray(this Int32 i)
        {
            return Convert.ToString(i, 2 /*for binary*/).Select(s => s.Equals('1')).ToArray();
        }
    }

    public static class BitArrayMath
    {
        /*
         * Seriously? You can't use operators in extensions?
         * http://stackoverflow.com/questions/172658/operator-overloading-with-c-sharp-extension-methods
         * 
         * 
         * 
         */
        public static BitArray Add(this BitArray bi, int val)
        {
            return BitArrayMathControl(bi, val, Operation.Add);
        }

        public static BitArray Subtract(this BitArray bi, int val)
        {
            return BitArrayMathControl(bi, val, Operation.Subtract);
        }
        private enum Operation {
            Add,
            Subtract
        }
        private static bool[] fullAdder(bool abit, bool bbit, bool cbit)
        {
            // bit 0 = sum bit
            // bit 1 = carry bit
            bool[] ret = new bool[2] { false, false };
            ret[0] = (abit ^ bbit) ^ cbit;
            ret[1] = (abit & bbit) | (bbit & cbit) | (abit & cbit);
            return ret;
        }

        private static bool[] fullSubtractor(bool xbit, bool ybit, bool zbit)
        {
            bool[] ret = new bool[2] { false, false };
            ret[0] = xbit ^ ybit ^ zbit;
            ret[1] = zbit & (xbit ^ ybit) | !xbit & ybit;
            return ret;
        }
        private static BitArray BitArrayMathControl(BitArray bi, int val, BitArrayMath.Operation op)
        {
            bool[] bits = new bool[bi.Count];
            bool[] result = new bool[2] { false, false };
            bool[] valboolarr = new bool[bi.Count];
            bool[] tmpboolarr = val.ToBooleanArray();

            for (int i = 0; i < tmpboolarr.Length; i++)
            {
                valboolarr[bi.Count - 1 - i] = tmpboolarr[tmpboolarr.Length - i - 1];
            }

            List<bool> valbits = new List<bool>();
            BitArray baval;
            baval = new BitArray(valboolarr);
            for (int i = bi.Count - 1; i >= 0; i--)
            {
                if (op == Operation.Add)
                    result = fullAdder(bi[i], baval[i], result[1]);
                else if (op == Operation.Subtract)
                    result = fullSubtractor(bi[i], baval[i], result[1]);
                bits[i] = result[0];
            }
            return new BitArray(bits);
        }
        public static bool bitsEqual(this BitArray bi1, BitArray bi2)
        {
            bool[] b1arr = new bool[bi1.Count];
            bool[] b2arr = new bool[bi2.Count];
            bi1.CopyTo(b1arr, 0);
            bi2.CopyTo(b2arr, 0);
            return (b1arr.SequenceEqual(b2arr)) ? true : false;
        }

        public static bool lessThan(this BitArray input, BitArray compare)
        {
            bool isequal;
            isequal = input.bitsEqual(compare);
            if (isequal)
                return false;
            if (BitArrayMath.BitArrayCompare(input, compare))
                return true;
            else
                return false;

        }

        public static bool greaterThan(this BitArray input, BitArray compare)
        {
            bool isequal;
            isequal = input.bitsEqual(compare);
            if (isequal)
                return false;
            if (BitArrayMath.BitArrayCompare(input, compare))
                return false;
            else
                return true;
        }

        public static bool lessThanOrEqual(this BitArray input, BitArray compare)
        {
            bool isequal;
            isequal = input.bitsEqual(compare);
            if (isequal)
                return true;
            if (BitArrayMath.BitArrayCompare(input, compare))
                return true;
            else
                return false;
        }

        public static bool greaterThanOrEqual(this BitArray input, BitArray compare)
        {
            bool isequal;
            isequal = input.bitsEqual(compare);
            if (isequal)
                return true;
            if (BitArrayMath.BitArrayCompare(input, compare))
                return false;
            else
                return true;
        }

        private static bool BitArrayCompare(BitArray bi1, BitArray bi2)
        {
            //Idea from -> http://mailman.linuxchix.org/pipermail/courses/2002-November/001043.html
            /*
             * true if bi1 < bi2
             * false if bi1 > bi2
             */
            for (int i = 0; i < bi1.Count; i++)
            {
                if (bi1[i] == true && bi2[i] != true)
                    return false;
                else if (bi1[i] != true && bi2[i] == true)
                    return true;
            }
            return false;
        }
    }

}

namespace Network
{

    public class InvalidIPFormat : System.Exception
    {
        public InvalidIPFormat(string msg) : base(msg)
        {

        }
        protected InvalidIPFormat(SerializationInfo info, StreamingContext ctxt) 
        : base(info, ctxt)
        { }
    }

    public class InvalidIP : System.Exception
    {
        public InvalidIP(string msg)
            : base(msg)
        {

        }
        protected InvalidIP(SerializationInfo info, StreamingContext ctxt)
            : base(info, ctxt)
        { }
    }

    public class InvalidIPInput : System.Exception
    {
        public InvalidIPInput(string msg)
            : base(msg)
        {

        }
        protected InvalidIPInput(SerializationInfo info, StreamingContext ctxt)
            : base(info, ctxt)
        { }
    }

    public class InvalidMask : System.Exception
    {
        public InvalidMask(string msg)
            : base(msg)
        {

        }
        protected InvalidMask(SerializationInfo info, StreamingContext ctxt)
            : base(info, ctxt)
        { }
    }

    public class IPNotSet : System.Exception
    {
        public IPNotSet(string msg)
            : base(msg)
        {

        }
        protected IPNotSet(SerializationInfo info, StreamingContext ctxt)
            : base(info, ctxt)
        { }
    }

}

namespace Network 
{
    /*
     * http://en.wikipedia.org/wiki/Logic_gate
     * http://en.wikibooks.org/wiki/Practical_Electronics/Adders
     * Algorithm:
     * 
     * 
     * full adder(abit, bbit, carrybit) returns sumbit and carrybit:
     * sumbit = ( abit XOR bbit ) XOR carrybit
     * carrybit = ( abit & bbit ) | ( bbit & carrybit ) | ( abit & carrybit) 
     * 
     * create bit array consisting of cidrbits - 32 set to zero
     * onarray = (numberofbits in rightarray - 1 set to zero) + one bit set to 1
     * carrybit = 0
     * sumarray = rightbitarray
     * 
     * 
     * while( rightbitarray =! finalip )
     *  if carrybit = 1
     *      break
     *  else
     *      ipaddr = cidrbitarry + sumarray
     *      convert each 8 bits of ipaddr to oct1, oct2, oct3, oct4
     *      print oct1 . oct2 . oct3 . oct4
     *      
     *  for i = 0 to rightbitarray.length
     *      abit = rightbitarray[0]
     *      bbit = onearray[0]
     *      sumbit, carrybit = full_adder(abit, bbit, carrybit)
     *      shift onrarray to the right by one - http://stackoverflow.com/questions/3684002/bitarray-shift-bits/7696793#7696793
     *      shift rightbitarray to the right by one
     *      sumarray += sumbit
     *  
     * 
     * 
     */
    public class IP
    {
        private BitArray cidr;
        private BitArray ipaddr;
        private int iptype;

        public IP(string ipaddr)
        {
            if (this.setIPv4(ipaddr))
                return;
            else if (this.setIPv6(ipaddr))
                return;
            else
                throw new Network.InvalidIPFormat("The input " + ipaddr + " was not a valid IP address in the proper format");
        }

        private bool setIPv4(string ipaddr)
        {
            List<string> iparr;
            List<string> ipcidrarr;
            
            //int cidr;
            if (ipaddr.Contains(":"))
                return false;
            if (ipaddr.Contains("/"))
            {
                ipcidrarr = ipaddr.Split('/').ToList();
                if (!this.isValidIPv4(ipcidrarr[0]))
                    throw new InvalidIP("The input " + ipaddr + " was not a valid IPv4" + " address in the proper format");
                iparr = ipcidrarr[0].Split('.').ToList();
                
                this.cidr = this.getCIDR(Int32.Parse(ipcidrarr[1]), 32);
            }
            else
            {
                if (!this.isValidIPv4(ipaddr))
                    throw new InvalidIP("The input " + ipaddr + " was not a valid IPv4" + " address in the proper format");
                iparr = ipaddr.Split('.').ToList();
            }
            if (iparr.Count != 4)
            {
                throw new Exception("Not enough octects");
            }
            else
            {
                this.ipaddr = this.IPv4ToBin(iparr);
            }
            this.iptype = 4;
            return true;
        }

        private BitArray IPv4ToBin(List<string> iparr)
        {
            List<bool> octarr;
            octarr = this.toBinary(Convert.ToInt32(iparr[0]), 8);
            octarr.AddRange(this.toBinary(Convert.ToInt32(iparr[1]), 8));
            octarr.AddRange(this.toBinary(Convert.ToInt32(iparr[2]), 8));
            octarr.AddRange(this.toBinary(Convert.ToInt32(iparr[3]), 8));
            //octarr.Reverse();
            return new BitArray(octarr.ToArray());
        }

        private BitArray IPv6ToBin(List<string> iparr)
        {
            List<bool> octarr;
            octarr = this.toBinary(Convert.ToInt32(iparr[0], 16), 16);
            octarr.AddRange(this.toBinary(Convert.ToInt32(iparr[1], 16), 16));
            octarr.AddRange(this.toBinary(Convert.ToInt32(iparr[2], 16), 16));
            octarr.AddRange(this.toBinary(Convert.ToInt32(iparr[3], 16), 16));
            octarr.AddRange(this.toBinary(Convert.ToInt32(iparr[4], 16), 16));
            octarr.AddRange(this.toBinary(Convert.ToInt32(iparr[5], 16), 16));
            octarr.AddRange(this.toBinary(Convert.ToInt32(iparr[6], 16), 16));
            octarr.AddRange(this.toBinary(Convert.ToInt32(iparr[8], 16), 16));
            //octarr.Reverse();
            return new BitArray(octarr.ToArray());
        }

        private List<bool> toBinary(int oct, int pad)
        {
            string binary = "";
            List<bool> biarr = new List<bool>();
            binary = Convert.ToString(oct, 2);
            binary = binary.PadLeft(pad, '0');
            foreach (char digit in binary)
            {
                switch (digit)
                {
                    case '0':
                        biarr.Add(false);
                        break;
                    case '1':
                        biarr.Add(true);
                        break;
                }
            }
            return biarr;
        }

        private BitArray getCIDR(int cidr, int numofbits)
        {
            List<bool> cidrbits = new List<bool>();
            for (int i = 0; i < cidr; i++)
            {
                cidrbits.Add(true);
            }
            if (cidrbits.Count < numofbits)
            {
                for (int i = 0; i < numofbits - cidr; i++)
                {
                    cidrbits.Add(false);
                }
            }
            return new BitArray(cidrbits.ToArray());
        }

        private bool setIPv6(string ipaddr)
        {
            List<string> ipv6 = new List<string>();
            List<string> ipv6arr = new List<string>();
            List<string> newipaddr = new List<string>();
            if (ipaddr.Contains("/"))
            {
                ipv6 = ipaddr.Split('/').ToList();
                this.cidr = this.getCIDR(Int32.Parse(ipv6[1]), 128);
                ipv6arr = ipv6[0].Split(':').ToList() ;
            }
            else
            {
                ipv6arr = ipaddr.Split(':').ToList();
            }
            newipaddr = this.fillIPv6Address(String.Join(":", ipv6arr.ToArray()));
            if (!this.isValidIPv6(String.Join(":", newipaddr.ToArray())))
                throw new InvalidIP("The input " + ipaddr + " was not a valid IPv" + 6 + " address in the proper format");
            this.ipaddr = this.IPv6ToBin(newipaddr);
            this.iptype = 6;
            return true;
        }

        private List<int> IPv6ToDec(List<string> ipaddr)
        {
            List<int> octs = new List<int>();
            foreach(string oct in ipaddr)
            {
                octs.Add(Convert.ToInt32(oct, 16));
            }
            return octs;
        }

        private bool isValidIPv4(string ipaddr)
        {
            List<string> iparr;
            int oct1, oct2, oct3, oct4;
            try
            {
                iparr = ipaddr.Split('.').ToList();
                oct1 = int.Parse(iparr[0]);
                oct2 = int.Parse(iparr[1]);
                oct3 = int.Parse(iparr[2]);
                oct4 = int.Parse(iparr[3]);
            }
            catch (Exception e)
            {
                throw new Exception("There was a problem converting the octects to ints", e);
            }
            if (oct1 <= 0 && oct1 >= 255)
                return false;
            if (oct2 <= 0 && oct2 >= 255)
                return false;
            if (oct3 <= 0 && oct3 >= 255)
                return false;
            if (oct4 <= 0 && oct4 >= 255)
                return false;
            return true;
        }

        private bool isValidIPv6(string ipaddr)
        {
            List<string> iparr;
            int oct1, oct2, oct3, oct4, oct5, oct6, oct7, oct8;
            try
            {
                iparr = ipaddr.Split(':').ToList();
                oct1 = Convert.ToInt32(iparr[0], 16);
                oct2 = Convert.ToInt32(iparr[1], 16);
                oct3 = Convert.ToInt32(iparr[2], 16);
                oct4 = Convert.ToInt32(iparr[3], 16);
                oct5 = Convert.ToInt32(iparr[4], 16);
                oct6 = Convert.ToInt32(iparr[5], 16);
                oct7 = Convert.ToInt32(iparr[6], 16);
                oct8 = Convert.ToInt32(iparr[7], 16);
            }
            catch (Exception e)
            {
                throw new Exception("There was a problem converting the octects to ints", e);
            }
            if (oct1 <= 0 && oct1 >= 0xFFFF)
                return false;
            if (oct2 <= 0 && oct2 >= 0xFFFF)
                return false;
            if (oct3 <= 0 && oct3 >= 0xFFFF)
                return false;
            if (oct4 <= 0 && oct4 >= 0xFFFF)
                return false;
            if (oct5 <= 0 && oct5 >= 0xFFFF)
                return false;
            if (oct6 <= 0 && oct6 >= 0xFFFF)
                return false;
            if (oct7 <= 0 && oct7 >= 0xFFFF)
                return false;
            if (oct8 <= 0 && oct8 >= 0xFFFF)
                return false;
            return true;
        }

        private List<string> fillIPv6Address(string ipstr)
        {
            List<string> sections = new List<string>();
            List<string> ipv6arr;
            string tmpip;
            int numofsections;
            if (ipstr.Contains("::"))
            {
                ipv6arr = ipstr.Split(':').ToList();
                numofsections = 8 - (from x in ipv6arr where x != "" select x).ToList().Count();
                for (int i = 0; i <= numofsections; i++)
                {
                    sections.Add("0000");
                }
                tmpip = ipstr.Replace("::", ":" + String.Join(":", sections.ToArray()) + ":");
                return tmpip.Trim(':').Split(':').ToList();
            }
            else
            {
                return ipstr.Split(':').ToList();
            }
        }

        private ArrayList getIPv6SubnetMask(int cidr)
        {
            if (this.iptype == 6)
            {
                List<bool> bits = new List<bool>();
                for (int i = 0; i <= cidr; i++)
                {
                    bits.Add(true);
                }
                for (int i = 0; i <= 128 - cidr; i++)
                {
                    bits.Add(false);
                }
                return new ArrayList(bits.ToArray());
            }
            else
            {
                return new ArrayList();
            }
        }

        public string getIPv4SubnetMask()
        {
            if (this.iptype == 4)
                return this.calcIPv4Address(this.cidr);
            else
                return "";
        }

        public string getIPv4Address()
        {
            
            return this.calcIPv4Address(this.ipaddr);

        }

        private string calcIPv4Address(BitArray ip)
        {
            bool[] bits = new bool[32];
            ip.CopyTo(bits, 0);
            List<bool> oct = new List<bool>(bits);
            int oct1, oct2, oct3, oct4;
            oct1 = this.bitsToDec(oct.GetRange(0, 8));
            oct2 = this.bitsToDec(oct.GetRange(8, 8));
            oct3 = this.bitsToDec(oct.GetRange(16, 8));
            oct4 = this.bitsToDec(oct.GetRange(24, 8));
            return String.Format("{0}.{1}.{2}.{3}",
                                oct1,
                                oct2,
                                oct3,
                                oct4);
        }

        private string calcIPv6Address(BitArray ip)
        {
            bool[] bits = new bool[128];
            ip.CopyTo(bits, 0);
            List<bool> oct = new List<bool>(bits);
            string oct1, oct2, oct3, oct4, oct5, oct6, oct7, oct8;
            oct1 = this.bitsToHex(oct.GetRange(0, 16));
            oct2 = this.bitsToHex(oct.GetRange(16, 16));
            oct3 = this.bitsToHex(oct.GetRange(32, 16));
            oct4 = this.bitsToHex(oct.GetRange(48, 16));
            oct5 = this.bitsToHex(oct.GetRange(64, 16));
            oct6 = this.bitsToHex(oct.GetRange(80, 16));
            oct7 = this.bitsToHex(oct.GetRange(96, 16));
            oct8 = this.bitsToHex(oct.GetRange(112, 16));
            return String.Format("{0}:{1}:{2}:{3}:{4}:{5}:{6}:{7}",
                                oct1,
                                oct2,
                                oct3,
                                oct4,
                                oct5,
                                oct6,
                                oct7,
                                oct8);
        }

        private int bitsToDec(List<bool> bits)
        {
            string bitstr = String.Join("", bits.ToArray());
            bitstr = bitstr.Replace("False", "0");
            bitstr = bitstr.Replace("True", "1");
            return Convert.ToInt32(bitstr, 2);
        }

        private string bitsToHex(List<bool> bits)
        {
            string bitstr = String.Join("", bits.ToArray());
            bitstr = bitstr.Replace("False", "0");
            bitstr = bitstr.Replace("True", "1");
            return Convert.ToInt32(bitstr, 2).ToString("X");
        }

        private BitArray calcIPv4FirstAddress()
        {
            // formula => ( ip & cidr ) + 1
            return (this.ipaddr.And(this.cidr).Add(1));
        }

        public string getIPv4FirstAddress()
        {
            return this.calcIPv4Address(this.calcIPv4FirstAddress());
        }

        public string getIPv4LastAddress()
        {
            return this.calcIPv4Address(this.calcIPv4LastAddress());
        }

        private BitArray calcIPv4LastAddress()
        {
            //formula => ( ip | ~cidr ) - 1
            BitArray tmp;
            // Not alters the variable itself so we have to NOT it here,
            // perform calculations, then NOT it later to reset the bits
            this.cidr.Not();
            tmp = this.ipaddr.Or(this.cidr);
            tmp = tmp.Subtract(1);
            this.cidr.Not();
            return tmp;
        }

        public string getIPv4NetworkAddress()
        {
            return this.calcIPv4Address(this.calcIPv4NetworkAddress());
        }

        private BitArray calcIPv4NetworkAddress()
        {
            //formula => ip & cidr
            return this.ipaddr.And(this.cidr);
        }

        private BitArray calcIPv4BroadcastAddress()
        {
            BitArray tmp;
            this.cidr.Not();
            tmp = this.ipaddr.Or(this.cidr);
            this.cidr.Not();
            return tmp;
        }

        public string getIPv4BroadcastAddress()
        {
            return this.calcIPv4Address(this.calcIPv4BroadcastAddress());
        }

        public List<string> getIPv4Range()
        {
            List<string> ipaddrs = new List<string>();
            BitArray currip = this.calcIPv4FirstAddress();
            BitArray lastip = this.calcIPv4LastAddress();
            while (!currip.bitsEqual(lastip))
            {
                ipaddrs.Add(this.calcIPv4Address(currip));
                currip = currip.Add(1);
            }
            ipaddrs.Add(this.calcIPv4Address(currip) );
            return ipaddrs;
        }

        public string getIPv6Address()
        {
            return this.calcIPv6Address(this.ipaddr);
        }
        
        private BitArray calcIPv6FirstAddress()
        {
            return this.ipaddr.And(this.cidr).Add(1);
        }

        public string getIPv6FirstAddress()
        {
            return this.calcIPv6Address(this.calcIPv6FirstAddress());
        }

        private BitArray cacIPv6LastAddress()
        {
            BitArray tmp;
            this.cidr.Not();
            tmp = this.ipaddr.Or(this.cidr);
            tmp = tmp.Subtract(1);
            this.cidr.Not();
            return tmp;
        }

        public string getIPv6LastAddress()
        {
            return this.calcIPv6Address(this.cacIPv6LastAddress());
        }

        public bool isIPv4AddressinRange(string ip)
        {
            if (ip.Contains(".") && this.isValidIPv4(ip))
            {
                BitArray inputip = this.IPv4ToBin(ip.Split('.').ToList());
                BitArray firstip = this.calcIPv4FirstAddress();
                BitArray lastip = this.calcIPv4LastAddress();
                if (inputip.greaterThanOrEqual(firstip) && inputip.lessThanOrEqual(lastip))
                    return true;
                else
                    return false;
            }
            else
            {
                return false;
            }
        }

        public List<string> getIPv6Range()
        {
            List<string> ipaddrs = new List<string>();
            BitArray currip = this.calcIPv6FirstAddress();
            BitArray lastip = this.cacIPv6LastAddress();
            
            while (!currip.bitsEqual(lastip))
            {
                ipaddrs.Add(this.calcIPv6Address(currip));
                currip = currip.Add(1);
            }
            ipaddrs.Add(this.calcIPv6Address(currip));
            return ipaddrs;

        }

        public bool isIPv6AddressinRange(string ip)
        {
            if (ip.Contains(":") && this.isValidIPv6(ip))
            {
                BitArray inputip = this.IPv6ToBin(ip.Split(':').ToList();
                BitArray firstip = this.calcIPv6FirstAddress();
                BitArray lastip = this.cacIPv6LastAddress();
                if (inputip.greaterThanOrEqual(firstip) && inputip.lessThanOrEqual(lastip))
                    return true;
                else
                    return false;
            }
            else
            {
                return false;
            }
        }
    }
}
