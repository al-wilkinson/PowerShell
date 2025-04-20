# PowerShell

Use the CIDR length.
```
$bitString = ('1' * $prefixLength).PadRight(32,'0')
```

Split into 4 separate strings of 8 chars and convert to integer equivalents.
```
$ipString=[String]::Empty
# make 1 string combining a string for each byte and convert to int
for($i=0;$i -lt 32;$i+=8){
  $byteString=$bitString.Substring($i,8)
  $ipString+="$([Convert]::ToInt64($byteString, 2))."
}
```

Consider 10.3.5.18/30
```
[ipaddress]"10.3.5.18"
```

Address            : 302318346 

Consider 30 bit net mask, ie 255.255.255.252
```
[ipaddress]"255.255.255.252"
```
Address            : 4244635647

'''
302318346 -band 4244635647
'''
Gives ```268763914``` which corresponds to the network address.