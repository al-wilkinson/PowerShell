function IPv4_to_Int {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ip
    )

    $octets = $ip.Split(".") | ForEach-Object {[int64]$_}
    
    $ipInt = ($octets[3] * 16777216) + ($octets[2] * 65536) + ($octets[1] * 256) + $octets[0]
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

$ip = "255.255.0.0"
$ipInt = IPv4_to_Int -ip $ip
Write-Host "Integer for '$ip' is: " $ipInt 
$calced = $ipInt % 16777216
Write-Host "Mod by 16777216: " $calced
# $ipInt.GetType()

$reversedInt_to_IP = Int_to_IPv4 -ipInt $ipInt
$reversedInt_to_IP

$reversedInt_to_IP = Int_to_IPv4 -ipInt 327690
$reversedInt_to_IP

