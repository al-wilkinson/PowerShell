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


function Get-ValidHostAddresses {
    param(
        [Parameter(Mandatory=$true)]
        [string]$IPRange
    )

    $arrayIPRange = Test-Valid-CIDR -IpRange $IPRange
    $IP_as_Int = $arrayIPRange[0].Address
    $mask = $arrayIPRange[1]

    Write-Host "The integer value for IP address: " $arrayIPRange[0] "is: " $IP_as_Int 
    Write-Host "The mask is: " $mask

    $totalAddresses = [Math]::Pow(2, (32 - $mask))
    Write-Host "The total number of addresses (including network and broadcast) is: " $totalAddresses
    $networkAddressInt = ($IP_as_Int % 16777216)
    Write-Host "The network address integer is: " $networkAddressInt
}

# Example usage:
$ipRange = "192.168.2.5/27"
$hostAddresses = Get-ValidHostAddresses -IpRange $ipRange
Write-Host "Valid host addresses for $($ipRange):"
$hostAddresses | ForEach-Object { Write-Host $_ }

$ipRange2 = "10.0.5.53/8"
$hostAddresses2 = Get-ValidHostAddresses -IpRange $ipRange2
Write-Host "`nValid host addresses for $($ipRange2):"
$hostAddresses2 | ForEach-Object { Write-Host $_ }

$invalidRange = "192.168.321.32/31"
Get-ValidHostAddresses -IpRange $invalidRange

$invalidFormat = "192.168.1.1"
Get-ValidHostAddresses -IpRange $invalidFormat
