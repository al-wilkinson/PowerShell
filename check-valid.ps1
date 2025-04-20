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

$value = Test-Valid-CIDR -IpRange "192.168.2.0/30"
$value[1]
$value[0]
