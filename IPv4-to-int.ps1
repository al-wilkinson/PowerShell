function IPv4_to_Int {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ip
    )

    $octets = $ip.Split(".") | ForEach-Object {[int32]$_}
    # $octets
    $octets.GetType()
    
    $ipInt = ($octets[0] * 16777216) + ($octets[1] * 65536) + ($octets[2] * 256) + $octets[3]
    # $ipInt
    return $ipInt
}

function Int_to_IPv4 {
    param (
        [Parameter(Mandatory=$true)]
        [int]$ipInt
    )

    $ipInt/16777216
    
}

$ip = "192.168.2.1"
$ipInt = IPv4_to_Int -ip $ip
Write-Host "Integer for '$ip' is: " $ipInt
$ipInt.GetType()

$reversedInt_to_IP = Int_to_IPv4 -ipInt $ipInt
$reversedInt_to_IP
