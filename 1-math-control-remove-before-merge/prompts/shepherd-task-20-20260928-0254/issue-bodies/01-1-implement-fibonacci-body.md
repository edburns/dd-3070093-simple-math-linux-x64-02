## Campaign context and required reading

On the `experiment/shepherd-control` branch, the directory `1-math-control-remove-before-merge` contains the plan (`math-tool-ignorance-reduction-plan.md`) and supporting resources (diagrams, decision records). Spike subdirectories are research artifacts — read the plan's Resolution sections for findings, not the spike source code.

Read the entire plan before working. Then carefully re-read these exact sections:

- `## Ignorance reduction`
- `### Repository-owned validation`
- `### Output and ordering contracts`
- `## Implementation`
- `### 1. Implement Fibonacci with unit and isolated CLI coverage`

The resolved validation decision is that the canonical acceptance command is `pwsh -NoLogo -NoProfile -File ./eng/test-math-tool.ps1`. The existing workflow `.github/workflows/shepherd-task-math-tool.yml` installs exactly Pester 5.7.1 and invokes that repository-owned runner. Do not replace, bypass, or duplicate the runner.

The resolved behavior contract is that direct CLI execution writes exactly one result line to stdout in the form `Fibonacci(N) = value`, while functions return only their numeric value and produce no incidental output. Inputs are non-negative integers. Production implementation and tests belong in the repository-root files `math-tool.ps1` and `math-tool.Tests.ps1`.

Research established these constraints directly; there is no spike implementation to copy. Implement production code and tests from scratch against the stated contracts.

## Branch and execution order

Use `experiment/shepherd-control` from remote `origin` as the PR base branch. This is task 1 of 2. The tasks are assigned, completed, and merged serially in plan order. Do not begin until this issue is assigned to you. Task 2 must not begin until this task is merged into the base branch.

Keep the PR limited to this issue. Do not merge or retarget the PR yourself.

## Implement

Create repository-root `math-tool.ps1` with:

- A script parameter named `N` that accepts a non-negative integer.
- A pure `Get-Fibonacci` function that computes and returns the Fibonacci value for `N`.
- Direct-execution behavior that invokes the function and writes exactly `Fibonacci(N) = value` followed only by the normal line terminator.
- No progress, diagnostic, debug, verbose, or other incidental output from the function or normal CLI execution.

Create repository-root `math-tool.Tests.ps1` with Pester coverage that:

- Dot-sources `math-tool.ps1` and tests `Get-Fibonacci` as a unit.
- Covers `N=0`, `N=1`, and at least one small representative value greater than 1.
- Launches isolated child `pwsh` processes to test direct CLI behavior rather than treating dot-sourced output as a CLI proxy.
- Verifies the child process exits successfully and stdout is exactly the required single result line for the covered inputs.
- Detects extra stdout so an implementation cannot pass by printing the expected line alongside incidental output.

Follow existing repository conventions and preserve compatibility with the pinned Pester 5.7.1 environment.

## Completion gates

- `pwsh -NoLogo -NoProfile -File ./eng/test-math-tool.ps1` exits zero.
- The repository-owned runner discovers and executes the new test file.
- Unit tests prove `Get-Fibonacci 0` returns numeric `0`, `Get-Fibonacci 1` returns numeric `1`, and the representative case returns the correct numeric value without extra pipeline output.
- Isolated process tests prove direct invocation for the covered inputs exits zero and emits exactly one stdout line matching `Fibonacci(N) = value`.
- The existing pinned pull-request CI passes.
- The PR targets `experiment/shepherd-control`.

## Out of scope

- Factorial support or an operation-dispatch parameter; those belong to task 2.
- Changes to the canonical test runner, workflow, Pester version, or CI configuration.
- New dependencies, generated artifacts, unrelated refactoring, or files beyond `math-tool.ps1` and `math-tool.Tests.ps1` unless a repository-required metadata update is unavoidable.
- Supporting negative or non-integer inputs beyond preserving the resolved non-negative-integer contract.
