# Function to test for valid input and split the input into an array of two elements.
function Test-Valid-CIDR {
    param(
        [Parameter(Mandatory=$true)]
        [string]$IpRange
    ) 
    
    # First validate the IP range format
    if ($IpRange -notmatch "^(\d{1,3}\.){3}\d{1,3}/\d{1,2}$") {
        Write-Error -Message "Invalid IP range format. Please use the format 'x.x.x.x/y'." -ErrorAction Stop
    }  
    
    # Split the IP address and subnet mask
    $parts = $IpRange.Split('/')
    $ipAddressString = $parts[0]
    $mask = [int]$parts[1]  
    
    if ($mask -lt 1 -or $mask -gt 30) {
        Write-Error -Message "Invalid CIDR value. Must be between 1 and 30." -ErrorAction Stop
    }    
    
    # Convert our IP Address String to a PowerShell object.  Trap an error if not a valid IP address.
    try {
        $objIPAddress = [ipaddress]$ipAddressString    
    }
    catch {
        Write-Error -Message "Error parsing IP address: $($_.Exception.Message)" -ErrorAction Stop
    }

    return $objIPAddress, $mask
}

# Function to calculate the network address as a little endian integer using a binary AND of the entered IP address and mask.
function Get-Net-Address {
    param (
        [Parameter(Mandatory=$true)]
        [int64]$IP_as_Int,
        [int]$mask
    )
    
    $prefixLength = $mask
    $bitString = ('1' * $prefixLength).PadRight(32,'0')
    Write-Host "function:Get-Net-Address - The mask bitstring is: " $bitString

    $ipString=[String]::Empty
    # make 1 string combining a string for each byte and convert to int
    for($i=0;$i -lt 32;$i+=8){
        $byteString=$bitString.Substring($i,8)
        $ipString+="$([Convert]::ToInt64($byteString, 2))"
        if ($i -lt 24) {$ipString+="."} # Otherwise we get a trailing period.
    } 
    
    Write-Host "function:Get-Net-Address - The mask is: " $ipString
    $maskInt = [ipaddress]$ipString 
    Write-Host "function:Get-Net-Address - The mask integer is: " $maskInt.Address
    Write-Host "function:Get-Net-Address - The IP integer passed to the function is: "$IP_as_Int
    
    # Now we have the mask and IP address as integers we can binary AND them to get the network address
    $netInt = $IP_as_Int -band $maskInt.Address

    # Write-Host "function:Get-Net-Address - The network address as integer is: " $netInt
    # $netAddr = [ipaddress]$netInt  
    # Write-Host "function:Get-Net-Address - Which is: "  $netAddr

    return $netInt   
}

function get-bigendian {
    param (
        [Parameter(Mandatory=$true)]
        [string]$netAddr
    )

    $octets = $netAddr.Split(".") | ForEach-Object {[int64]$_}

    $bigendianNetIPInt = ($octets[0] * 16777216) + ($octets[1] * 65536) + ($octets[2] * 256) + $octets[3]
    return $bigendianNetIPInt  


}


function bigendianIPv4_to_Int {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ip
    )

    $octets = $ip.Split(".") | ForEach-Object {[int64]$_}
    
    $ipInt = ($octets[0] * 16777216) + ($octets[1] * 65536) + ($octets[2] * 256) + $octets[3]
    return $ipInt
}

function bigendianInt_to_IPv4 {
    param (
        [Parameter(Mandatory=$true)]
        [int64]$ipInt
    )

    $octet1 = $ipInt%256
    $octet2 = (($ipInt%65536)-$octet1)/256
    $octet3 = (($ipInt%16777216)-$octet2*256-$octet1)/65536
    $octet4 = (($ipInt-$octet3*65536-$octet2*256-$octet1)/16777216)
    
    $strIP = [string]$octet4 + "." + [string]$octet3 + "." + [string]$octet2 + "." + [string]$octet1
    # Write-Host "function:bigendianInt_to_IPv4 - address string: "  $strIP
    return $strIP
}

function Get-Hosts {
    param (
        [Parameter(Mandatory=$true)]
        [int64]$totalHosts,
        [int64]$bigendianNetIPInt
    )

    $arrayIPAddresses = @()
    for ($i = $bigendianNetIPInt + 1; $i -lt $bigendianNetIPInt + $totalHosts; $i++) {
        $ip = bigendianInt_to_IPv4 -ipInt $i
        $arrayIPAddresses += $ip
    }

    # Write-Host "function:Get-Hosts - IP array : " $arrayIPAddresses
    return $arrayIPAddresses
}

function Get-ValidHostAddresses {
    param(
        [Parameter(Mandatory=$true)]
        [string]$IPRange
    )

    # Test for valid input string and split CIDR notation into an array of littleendian address integer and subnet mask
    $arrayIPRange = Test-Valid-CIDR -IpRange $IPRange
    $IP_as_Int = $arrayIPRange[0].Address
    $mask = $arrayIPRange[1]

    # Get the network address for the given IP address and subnet mask
    $netInt = Get-Net-Address -IP_as_Int $IP_as_Int -mask $mask
    Write-Host "function:Get-ValidHostAddresses - The network address as integer is: " $netInt
    # Use the PowerShell [IPAddress] class to check returned value.
    $netAddr = [ipaddress]$netInt  
    Write-Host "function:Get-ValidHostAddresses - Which is: "  $netAddr
    Write-Host "function:Get-ValidHostAddresses - The integer value for IP address: " $arrayIPRange[0] "is: " $IP_as_Int 
    Write-Host "function:Get-ValidHostAddresses - The mask is: " $mask

    $totalAddresses = [Math]::Pow(2, (32 - $mask))
    Write-Host "function:Get-ValidHostAddresses - The total number of addresses (including network and broadcast) is: " $totalAddresses
    # It is much easier to calculate the valid IP addresses in the range in bigendian format.  Should this be some elegant bit manipulation of the integer?
    $bigendianNetIPInt = get-bigendian -netAddr $netAddr
    Write-Host "function:Get-ValidHostAddresses - The bigendian network integer is: " $bigendianNetIPInt

    $arrayIPAddresses = Get-Hosts -totalHosts $totalAddresses -bigendianNetIPInt $bigendianNetIPInt
    Write-Host "function:Get-ValidHostAddresses - IP array : " $arrayIPAddresses
    ForEach ($ip in $arrayIPAddresses) {
        Test-Connection -ComputerName $ip -Count 2
    }
}

$ipRange = $args[0]
Write-Host "-------------------------------------------------------------"
Write-Host "Values for $($ipRange):"
Get-ValidHostAddresses -IpRange $ipRange
