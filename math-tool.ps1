[CmdletBinding()]
param(
    [ValidateRange(0, [int]::MaxValue)]
    [int]$N = 0
)

function Get-Fibonacci {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$N
    )

    $previous = 0
    $current = 1
    for ($i = 0; $i -lt $N; $i++) {
        $next = $previous + $current
        $previous = $current
        $current = $next
    }

    return $previous
}

$script:IsDotSourced = ($MyInvocation.InvocationName -eq '.') -or ($MyInvocation.CommandOrigin -eq 'Internal')
if (-not $script:IsDotSourced) {
    $value = Get-Fibonacci -N $N
    Write-Output "Fibonacci($N) = $value"
}
