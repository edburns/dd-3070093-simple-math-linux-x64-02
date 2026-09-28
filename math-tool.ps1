[CmdletBinding()]
param(
    [ValidateSet('fibonacci', 'factorial')]
    [string]$Operation = 'fibonacci',

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

    $previous = [System.Numerics.BigInteger]::Zero
    $current = [System.Numerics.BigInteger]::One
    for ($i = 0; $i -lt $N; $i++) {
        $next = $previous + $current
        $previous = $current
        $current = $next
    }

    return $previous
}

function Get-Factorial {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$N
    )

    $value = [System.Numerics.BigInteger]::One
    for ($i = 2; $i -le $N; $i++) {
        $value *= $i
    }

    return $value
}

# When this file is dot-sourced (". ./math-tool.ps1"), PowerShell sets
# $MyInvocation.InvocationName to the literal string '.' for the script's own
# invocation record. When invoked directly (e.g. "pwsh -File math-tool.ps1"),
# InvocationName is the script path instead. This distinguishes "load the
# functions" from "run the CLI" so dot-sourcing never produces incidental
# stdout.
if ($MyInvocation.InvocationName -ne '.') {
    switch ($Operation) {
        'fibonacci' {
            $value = Get-Fibonacci -N $N
            Write-Output "Fibonacci($N) = $value"
        }
        'factorial' {
            $value = Get-Factorial -N $N
            Write-Output "Factorial($N) = $value"
        }
    }
}
