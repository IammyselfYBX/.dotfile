[CmdletBinding()]
param(
    [int]$LocalPort = 22222,
    [string]$JumpHost = 'bastion',
    [string]$TargetHost = '203.0.113.10',
    [int]$TargetPort = 2223,
    [string]$TargetUser = 'deploy',
    [string]$IdentityFile = (Join-Path $HOME '.ssh\id_ed25519'),
    [string]$WezTermExe = 'C:\Tools\WezTerm\wezterm.exe',
    [string]$SshExe = "$env:SystemRoot\System32\OpenSSH\ssh.exe",
    [switch]$StopTunnel
)

$ErrorActionPreference = 'Stop'
$pidFile = Join-Path $env:TEMP 'codex-work-tunnel.pid'

function Test-LocalPort {
    param([int]$Port)
    $client = [Net.Sockets.TcpClient]::new()
    try {
        $task = $client.ConnectAsync('127.0.0.1', $Port)
        return $task.Wait(300) -and $client.Connected
    } catch {
        return $false
    } finally {
        $client.Dispose()
    }
}

if ($StopTunnel) {
    if (Test-Path -LiteralPath $pidFile) {
        $tunnelPid = [int](Get-Content -LiteralPath $pidFile -Raw)
        $process = Get-Process -Id $tunnelPid -ErrorAction SilentlyContinue
        if ($process -and $process.ProcessName -eq 'ssh') {
            Stop-Process -Id $tunnelPid -Force
            Write-Host "Stopped SSH tunnel PID $tunnelPid"
        }
        Remove-Item -LiteralPath $pidFile -Force -ErrorAction SilentlyContinue
    } else {
        Write-Host 'No tunnel PID file found.'
    }
    return
}

$reuse = $false
if (Test-Path -LiteralPath $pidFile) {
    $tunnelPid = [int](Get-Content -LiteralPath $pidFile -Raw)
    $process = Get-Process -Id $tunnelPid -ErrorAction SilentlyContinue
    if ($process -and $process.ProcessName -eq 'ssh' -and (Test-LocalPort $LocalPort)) {
        $reuse = $true
        Write-Host "Reusing SSH tunnel PID $tunnelPid on 127.0.0.1:$LocalPort"
    } else {
        Remove-Item -LiteralPath $pidFile -Force -ErrorAction SilentlyContinue
    }
}

if (-not $reuse) {
    if (Test-LocalPort $LocalPort) {
        throw "Local port $LocalPort is already in use. Run with -LocalPort another free port."
    }

    $args = @(
        '-N',
        '-o', 'ExitOnForwardFailure=yes',
        '-o', 'ServerAliveInterval=30',
        '-o', 'ServerAliveCountMax=3',
        '-L', "${LocalPort}:${TargetHost}:${TargetPort}",
        $JumpHost
    )
    $tunnel = Start-Process -FilePath $SshExe -ArgumentList $args -WindowStyle Hidden -PassThru
    Set-Content -LiteralPath $pidFile -Value $tunnel.Id -Encoding ascii

    $ready = $false
    for ($i = 0; $i -lt 40; $i++) {
        Start-Sleep -Milliseconds 250
        $tunnel.Refresh()
        if ($tunnel.HasExited) {
            Remove-Item -LiteralPath $pidFile -Force -ErrorAction SilentlyContinue
            throw "SSH tunnel exited with code $($tunnel.ExitCode). Verify that 'ssh bastion' works."
        }
        if (Test-LocalPort $LocalPort) {
            $ready = $true
            break
        }
    }
    if (-not $ready) {
        Stop-Process -Id $tunnel.Id -Force -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath $pidFile -Force -ErrorAction SilentlyContinue
        throw "SSH tunnel did not open local port $LocalPort."
    }
    Write-Host "SSH tunnel started, PID $($tunnel.Id): 127.0.0.1:$LocalPort -> $TargetHost`:$TargetPort via $JumpHost"
}

$target = "$TargetUser@127.0.0.1:$LocalPort"
Write-Host "Opening: $WezTermExe ssh $target"
try {
    & $WezTermExe ssh -o "IdentityFile=$IdentityFile" -o 'IdentitiesOnly=yes' $target
}
finally {
    if (-not $reuse -and (Test-Path -LiteralPath $pidFile)) {
        $tunnelPid = [int](Get-Content -LiteralPath $pidFile -Raw)
        $process = Get-Process -Id $tunnelPid -ErrorAction SilentlyContinue
        if ($process -and $process.ProcessName -eq 'ssh') {
            Stop-Process -Id $tunnelPid -Force -ErrorAction SilentlyContinue
        }
        Remove-Item -LiteralPath $pidFile -Force -ErrorAction SilentlyContinue
    }
}