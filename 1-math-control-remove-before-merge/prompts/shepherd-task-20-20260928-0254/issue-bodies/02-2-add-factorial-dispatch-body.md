## Campaign context and required reading

On the `experiment/shepherd-control` branch, the directory `1-math-control-remove-before-merge` contains the plan (`math-tool-ignorance-reduction-plan.md`) and supporting resources (diagrams, decision records). Spike subdirectories are research artifacts — read the plan's Resolution sections for findings, not the spike source code.

Read the entire plan before working. Then carefully re-read these exact sections:

- `## Ignorance reduction`
- `### Repository-owned validation`
- `### Output and ordering contracts`
- `## Implementation`
- `### 1. Implement Fibonacci with unit and isolated CLI coverage`
- `### 2. Add factorial and operation dispatch`

The resolved validation decision is that the canonical acceptance command is `pwsh -NoLogo -NoProfile -File ./eng/test-math-tool.ps1`. The existing workflow `.github/workflows/shepherd-task-math-tool.yml` installs exactly Pester 5.7.1 and invokes that repository-owned runner. Do not replace, bypass, or duplicate the runner.

The resolved behavior contract is that direct CLI execution writes exactly one result line to stdout: `Fibonacci(N) = value` or `Factorial(N) = value`. Functions return only numeric values and produce no incidental output. Inputs are non-negative integers. Production implementation and tests remain in repository-root `math-tool.ps1` and `math-tool.Tests.ps1`. Fibonacci behavior delivered by task 1 is a required regression contract.

Research established these constraints directly; there is no spike implementation to copy. Implement the production extension and tests from scratch against the stated contracts.

## Branch and execution order

Use `experiment/shepherd-control` from remote `origin` as the PR base branch. This is task 2 of 2, and it depends on task 1 already being merged into that branch. The tasks are assigned, completed, and merged serially in plan order. Do not begin until this issue is assigned to you and task 1 is present on the base branch.

Keep the PR limited to this issue. Do not merge or retarget the PR yourself.

## Implement

Extend the existing repository-root `math-tool.ps1`:

- Add a pure `Get-Factorial` function that accepts `N` and returns its numeric factorial value.
- Add an `Operation` parameter that dispatches between `fibonacci` and `factorial` while retaining the existing `N` parameter.
- Preserve all task-1 Fibonacci function and direct-CLI behavior.
- For Fibonacci dispatch, direct execution must write exactly `Fibonacci(N) = value`.
- For factorial dispatch, direct execution must write exactly `Factorial(N) = value`.
- Ensure both functions return only their numeric values and normal CLI execution emits no progress, diagnostic, debug, verbose, or other incidental output.

Extend `math-tool.Tests.ps1` using objective Pester coverage. The plan intentionally leaves the exact organization of the extension to this task, but the suite must:

- Unit-test `Get-Factorial` for `N=0`, `N=1`, and at least one small representative value greater than 1.
- Exercise factorial through an isolated child `pwsh` process and verify successful exit plus the exact single result line.
- Retain or strengthen the existing Fibonacci unit and isolated CLI regression coverage.
- Exercise both operation values through the public script interface so dispatch errors cannot be hidden by function-only tests.
- Detect extra stdout for both operations.

Follow existing repository conventions and preserve compatibility with the pinned Pester 5.7.1 environment.

## Completion gates

- `pwsh -NoLogo -NoProfile -File ./eng/test-math-tool.ps1` exits zero for the combined regression suite.
- Unit tests prove factorial edge cases `0! = 1` and `1! = 1`, plus a representative factorial value, are numeric and have no extra pipeline output.
- Isolated process tests prove both operation values exit zero and emit exactly one correctly capitalized stdout line with the computed value.
- Fibonacci cases from task 1 continue to pass unchanged.
- The repository-owned runner discovers and executes the combined test suite.
- The existing pinned pull-request CI passes.
- The PR targets `experiment/shepherd-control`.

## Out of scope

- Additional operations beyond `fibonacci` and `factorial`.
- Changes to the canonical test runner, workflow, Pester version, or CI configuration.
- New dependencies, generated artifacts, unrelated refactoring, or files beyond `math-tool.ps1` and `math-tool.Tests.ps1` unless a repository-required metadata update is unavoidable.
- Supporting negative or non-integer inputs beyond preserving the resolved non-negative-integer contract.
