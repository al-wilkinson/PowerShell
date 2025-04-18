function Get-ValidHostAddresses {
    param(
        [Parameter(Mandatory=$true)]
        [string]$IpRange
    )

    # Validate the IP range format
    if ($IpRange -notmatch "^(\d{1,3}\.){3}\d{1,3}/\d{1,2}$") {
        Write-Host "Invalid IP range format. Please use the format 'x.x.x.x/y'."
        return
    }

    Write-Host 'IP addr: ' $IpRange
    # Split the IP address and subnet mask
    $parts = $IpRange.Split('/')
    $ipAddress = $parts[0]
    $cidr = [int]$parts[1]
    Write-Host 'mask: ' $cidr

    # Validate CIDR value
    if ($cidr -lt 1 -or $cidr -gt 30) {
        Write-Host "Invalid CIDR value. Must be between 1 and 30."
        return
    }

    # Convert IP address to an integer
    $ipBytes = $ipAddress.Split('.') | ForEach-Object {[int]$_}
    Write-Host 'Octets: ' $ipBytes
    $ipInt = ($ipBytes[0] * 16777216) + ($ipBytes[1] * 65536) + ($ipBytes[2] * 256) + $ipBytes[3]

    # Calculate the number of hosts
    $numHosts = [Math]::Pow(2, (32 - $cidr))
    Write-Host 'Number of hosts: ' $numHosts

    # Calculate the network address
    $networkAddressInt = $ipInt - ($ipInt % $numHosts)
    Write-Host 'Network address Integer: ' $networkAddressInt

    # Calculate the broadcast address
    $broadcastAddressInt = $networkAddressInt + $numHosts - 1
    Write-Host 'Broadcast address Integer': $broadcastAddressInt

    # Loop through all possible addresses and return valid hosts
    $validHosts = @()
    for ($i = 1; $i -lt ($numHosts - 1); $i++) {
        $hostAddressInt = $networkAddressInt + $i
        $hostAddressBytes = @()
        for ($j = 3; $j -ge 0; $j--) {
            $hostAddressBytes += ($hostAddressInt - ($hostAddressInt % [Math]::Pow(256, $j))) / [Math]::Pow(256, $j)
            $hostAddressInt = $hostAddressInt % [Math]::Pow(256, $j)
        }
        $validHosts += ($hostAddressBytes -join '.')
    }

    return $validHosts
}

# Example usage:
$ipRange = "192.168.2.0/27"
$hostAddresses = Get-ValidHostAddresses -IpRange $ipRange
Write-Host "Valid host addresses for $($ipRange):"
$hostAddresses | ForEach-Object { Write-Host $_ }

$ipRange2 = "10.0.5.53/29"
$hostAddresses2 = Get-ValidHostAddresses -IpRange $ipRange2
Write-Host "`nValid host addresses for $($ipRange2):"
$hostAddresses2 | ForEach-Object { Write-Host $_ }

$invalidRange = "192.168.321.32/30"
Get-ValidHostAddresses -IpRange $invalidRange

$invalidFormat = "192.168.1.1"
Get-ValidHostAddresses -IpRange $invalidFormat
