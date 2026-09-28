BeforeAll {
    $script:MathToolPath = Join-Path $PSScriptRoot 'math-tool.ps1'
    . $script:MathToolPath
}

Describe 'Get-Fibonacci (unit)' {
    It 'returns 0 for N=0' {
        Get-Fibonacci -N 0 | Should -Be 0
    }

    It 'returns 1 for N=1' {
        Get-Fibonacci -N 1 | Should -Be 1
    }

    It 'returns 55 for N=10 (representative value)' {
        Get-Fibonacci -N 10 | Should -Be 55
    }

    It 'returns an exact value beyond the Int64 range' {
        Get-Fibonacci -N 93 | Should -Be ([System.Numerics.BigInteger]::Parse('12200160415121876738'))
    }
}

Describe 'Get-Factorial (unit)' {
    It 'returns only numeric 1 for N=0' {
        $result = @(Get-Factorial -N 0)

        $result.Count | Should -Be 1
        $result[0] | Should -BeOfType ([System.Numerics.BigInteger])
        $result[0] | Should -Be 1
    }

    It 'returns only numeric 1 for N=1' {
        $result = @(Get-Factorial -N 1)

        $result.Count | Should -Be 1
        $result[0] | Should -BeOfType ([System.Numerics.BigInteger])
        $result[0] | Should -Be 1
    }

    It 'returns only numeric 120 for N=5' {
        $result = @(Get-Factorial -N 5)

        $result.Count | Should -Be 1
        $result[0] | Should -BeOfType ([System.Numerics.BigInteger])
        $result[0] | Should -Be 120
    }
}

Describe 'math-tool.ps1 direct CLI invocation (isolated process)' {
    BeforeAll {
        function Invoke-MathToolProcess {
            param(
                [string]$Operation,
                [int]$N
            )

            $pwsh = (Get-Process -Id $PID).Path
            $stdoutPath = [System.IO.Path]::GetTempFileName()
            $stderrPath = [System.IO.Path]::GetTempFileName()
            try {
                $process = Start-Process -FilePath $pwsh `
                    -ArgumentList @('-NoLogo', '-NoProfile', '-File', $script:MathToolPath, '-Operation', $Operation, '-N', $N) `
                    -NoNewWindow -PassThru -Wait `
                    -RedirectStandardOutput $stdoutPath `
                    -RedirectStandardError $stderrPath

                [PSCustomObject]@{
                    ExitCode = $process.ExitCode
                    StdOut   = Get-Content -LiteralPath $stdoutPath -Raw
                    StdErr   = Get-Content -LiteralPath $stderrPath -Raw
                }
            }
            finally {
                Remove-Item -LiteralPath $stdoutPath -ErrorAction SilentlyContinue
                Remove-Item -LiteralPath $stderrPath -ErrorAction SilentlyContinue
            }
        }
    }

    It 'exits zero and writes exactly one result line for <Operation> N=<N>' -TestCases @(
        @{ Operation = 'fibonacci'; N = 0; Expected = 'Fibonacci(0) = 0' }
        @{ Operation = 'fibonacci'; N = 1; Expected = 'Fibonacci(1) = 1' }
        @{ Operation = 'fibonacci'; N = 10; Expected = 'Fibonacci(10) = 55' }
        @{ Operation = 'factorial'; N = 0; Expected = 'Factorial(0) = 1' }
        @{ Operation = 'factorial'; N = 1; Expected = 'Factorial(1) = 1' }
        @{ Operation = 'factorial'; N = 5; Expected = 'Factorial(5) = 120' }
    ) {
        param($Operation, $N, $Expected)

        $result = Invoke-MathToolProcess -Operation $Operation -N $N

        $result.ExitCode | Should -Be 0
        $result.StdOut | Should -Be "$Expected`n"
        $result.StdErr | Should -BeNullOrEmpty
    }
}
