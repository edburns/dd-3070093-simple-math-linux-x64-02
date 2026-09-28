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
}

Describe 'math-tool.ps1 direct CLI invocation (isolated process)' {
    BeforeAll {
        function Invoke-MathToolProcess {
            param(
                [int]$N
            )

            $pwsh = (Get-Process -Id $PID).Path
            $stdoutPath = [System.IO.Path]::GetTempFileName()
            $stderrPath = [System.IO.Path]::GetTempFileName()
            try {
                $process = Start-Process -FilePath $pwsh `
                    -ArgumentList @('-NoLogo', '-NoProfile', '-File', $script:MathToolPath, '-N', $N) `
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

    It 'exits zero and writes exactly one result line for N=<N>' -TestCases @(
        @{ N = 0; Expected = 0 }
        @{ N = 1; Expected = 1 }
        @{ N = 10; Expected = 55 }
    ) {
        param($N, $Expected)

        $result = Invoke-MathToolProcess -N $N

        $result.ExitCode | Should -Be 0

        $lines = @($result.StdOut -split "`r?`n" | Where-Object { $_ -ne '' })
        $lines.Count | Should -Be 1
        $lines[0] | Should -Be "Fibonacci($N) = $Expected"
    }
}
