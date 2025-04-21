function IPv4_to_Int {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ip
    )

    $octets = $ip.Split(".") | ForEach-Object {[int64]$_}
    
    $ipInt = ($octets[0] * 16777216) + ($octets[1] * 65536) + ($octets[2] * 256) + $octets[3]
    return $ipInt
}

function Int_to_IPv4 {
    param (
        [Parameter(Mandatory=$true)]
        [int64]$ipInt
    )

    $octet1 = $ipInt%256
    $octet2 = (($ipInt%65536)-$octet1)/256
    $octet3 = (($ipInt%16777216)-$octet2*256-$octet1)/65536
    $octet4 = (($ipInt-$octet3*65536-$octet2*256-$octet1)/16777216)

    $octet1
    $octet2
    $octet3
    $octet4   
}

$ip = "10.3.4.254"
$ipInt = IPv4_to_Int -ip $ip
Write-Host "Integer for '$ip' is: " $ipInt 

$reversedInt_to_IP = Int_to_IPv4 -ipInt $ipInt
$reversedInt_to_IP


