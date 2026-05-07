param(
    [string]$PythonPath = ".\.venv\Scripts\python.exe"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $PythonPath)) {
    $pythonCommand = Get-Command $PythonPath -ErrorAction SilentlyContinue
    if ($pythonCommand) {
        $PythonPath = $pythonCommand.Source
    }
    else {
        throw "Python virtual environment was not found at $PythonPath. Run scripts\setup.ps1 first."
    }
}

& $PythonPath -m unittest discover -s tests -v
if ($LASTEXITCODE -ne 0) {
    throw "Unit tests failed with exit code $LASTEXITCODE."
}

if (Test-Path -LiteralPath "frontend\package.json") {
    Push-Location frontend
    try {
        npm run build
        if ($LASTEXITCODE -ne 0) {
            throw "Frontend build failed with exit code $LASTEXITCODE."
        }
    }
    finally {
        Pop-Location
    }
}
else {
    Write-Host "Skipping frontend build; frontend\package.json was not found."
}

Write-Host ""
Write-Host "Production check passed."
