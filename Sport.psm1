function Sport {
<# 
.SYNOPSIS
Scan TCP port on remote host.

.DESCRIPTION
Sport try to connect to TCP-port on specified host.

.PARAMETER ComputerName
Host or ip address.

.PARAMETER Port
Port number.

.PARAMETER Timeout
Connection timeout in milliseconds.

.OUTPUTS 
System.Boolean

Function returns $TRUE, if port opened, $FALSE if port closed or $NULL when any exception occurs.

.EXAMPLE
sport localhost 445
# Test port 445 on localhost.
.EXAMPLE

sport -Port 445 -ComputerName localhost -Verbose
# Same as above, but order of parameters was swapped and vrebose output requested.

.NOTES
Simplest inline version of our script may be helpful:

function stp($c, $p) { try { $s=[Net.Sockets.TcpClient]::new($c,$p); $s.Connected; $s.close() } catch { $FALSE } }
#>

[CmdletBinding()]

param (
    [String]$ComputerName = "localhost", 
    [Int]$Port = 135,
    [Int]$Timeout = 100
)

    if ($PSBoundParameters.ContainsKey("Verbose") -and $PSBoundParameters['Verbose']) {
        $VerbosePreference = "Continue"
    }

    $Socket = [Net.Sockets.TcpClient]::new()

    try {
        Write-Verbose "Test ${ComputerName}:${Port}, timeout ${Timeout}"
        $WaitHandleResult = $Socket.BeginConnect($ComputerName, $Port, $NULL, $NULL).AsyncWaitHandle.WaitOne($Timeout)
        if (-not $WaitHandleResult) {
            Write-Verbose "Timeout occurs"
        }
        $Result = $Socket.Connected 
    } catch { 
        $Result = $NULL
        Write-Verbose "Fail"
        throw $_.exception 
    } 

    $Socket.close()

    if ($Result) {
        Write-Verbose "Port opened."
    } else {
        Write-Verbose "Port closed."
    }
     
    return $Result
}

