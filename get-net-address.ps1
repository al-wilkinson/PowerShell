function Get-Net-Address {
    param(
        [Parameter(Mandatory=$true)]
        [int]$mask
    ) 

    $prefixLength = $mask
    $bitString = ('1' * $prefixLength).PadRight(32,'0')

    $ipString=[String]::Empty
    # make 1 string combining a string for each byte and convert to int
    for($i=0;$i -lt 32;$i+=8){
        $byteString=$bitString.Substring($i,8)
        $ipString+="$([Convert]::ToInt64($byteString, 2))"
        if ($i -lt 24) {$ipString+="."} # Otherwise we get a trailing period.
    }

    Write-Host $ipString
    $maskInt = [ipaddress]$ipString

    # Some test values
    $ip = "192.168.2.155"
    $ipInt = [ipaddress]$ip
    $netInt = $ipInt.Address -band $maskInt.Address
    $netInt
    [ipaddress]$netInt
}

Get-Net-Address -mask 27
