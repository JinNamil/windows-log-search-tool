$iniFile = ".\keywords.ini"
$resultFile = ".\search_result.txt"

if (!(Test-Path -LiteralPath $iniFile)) {
    Write-Host "INI file not found: $iniFile"
    exit 1
}

$targetPath = ""
$keywords = @()
$section = ""

$repeat = $false
$intervalSec = 300
$ntfyTopic = ""

Get-Content -LiteralPath $iniFile | ForEach-Object {
    $line = $_.Trim()

    if ($line -eq "") { return }
    if ($line.StartsWith(";")) { return }
    if ($line.StartsWith("#")) { return }

    if ($line.StartsWith("[") -and $line.EndsWith("]")) {
        $section = $line.Trim("[", "]").ToLower()
        return
    }

    $parts = $line -split "=", 2
    if ($parts.Count -ne 2) { return }

    $key = $parts[0].Trim()
    $value = $parts[1].Trim()

    if ($section -eq "config") {
        if ($key.ToLower() -eq "target") {
            $targetPath = $value
        }
        elseif ($key.ToLower() -eq "repeat") {
            $repeat = ($value.ToLower() -eq "true")
        }
        elseif ($key.ToLower() -eq "interval_sec") {
            $intervalSec = [int]$value
        }
        elseif ($key.ToLower() -eq "ntfy_topic") {
            $ntfyTopic = $value
        }
    }
    elseif ($section -eq "keywords") {
        if ($value -ne "") {
            $keywords += $value
        }
    }
}

if ($targetPath -eq "") {
    Write-Host "target is not set in ini file."
    exit 1
}

if (!(Test-Path -LiteralPath $targetPath)) {
    Write-Host "Target path not found: $targetPath"
    exit 1
}

if ($keywords.Count -eq 0) {
    Write-Host "No keywords found in ini file."
    exit 1
}

if ($repeat -and $intervalSec -le 0) {
    Write-Host "interval_sec must be greater than 0."
    exit 1
}

"Search Result" | Out-File -LiteralPath $resultFile -Encoding utf8

do {
    $item = Get-Item -LiteralPath $targetPath

    if ($item.PSIsContainer) {
        $files = Get-ChildItem -LiteralPath $targetPath -File -Recurse |
            Where-Object {
                $_.Extension -match '^\.(txt|log|ini|csv|xml|json|c|cpp|h|hpp|py|bat|ps1)$'
            }
    }
    else {
        $files = @($item)
    }

    $counts = @{}
    foreach ($k in $keywords) {
        $counts[$k] = 0
    }

    $searchTime = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

    "" | Out-File -LiteralPath $resultFile -Append -Encoding utf8
    "=========================================" | Out-File -LiteralPath $resultFile -Append -Encoding utf8
    "Search Start : $searchTime" | Out-File -LiteralPath $resultFile -Append -Encoding utf8
    "Target: $targetPath" | Out-File -LiteralPath $resultFile -Append -Encoding utf8
    "File Count: $($files.Count)" | Out-File -LiteralPath $resultFile -Append -Encoding utf8
    "=========================================" | Out-File -LiteralPath $resultFile -Append -Encoding utf8

    Write-Host ""
    Write-Host "========================================="
    Write-Host "Search Start : $searchTime"
    Write-Host "Target: $targetPath"
    Write-Host "File Count: $($files.Count)"
    Write-Host "========================================="

    foreach ($fileItem in $files) {
        $file = $fileItem.FullName
        $lineNo = 0

        Get-Content -LiteralPath $file -ReadCount 1000 -ErrorAction SilentlyContinue | ForEach-Object {
            foreach ($line in $_) {
                $lineNo++

                foreach ($k in $keywords) {
                    if ($line.Contains($k)) {
                        $counts[$k]++

                        "$file`:$lineNo`:$line" |
                            Out-File -LiteralPath $resultFile -Append -Encoding utf8
                    }
                }
            }
        }
    }

    "" | Out-File -LiteralPath $resultFile -Append -Encoding utf8
    "Summary" | Out-File -LiteralPath $resultFile -Append -Encoding utf8
    "=========================================" | Out-File -LiteralPath $resultFile -Append -Encoding utf8

    $summaryLines = @()
    $summaryLines += "[LOG SEARCH SUMMARY]"
    $summaryLines += "Time: $searchTime"
    $summaryLines += "Target: $targetPath"
    $summaryLines += "File Count: $($files.Count)"
    $summaryLines += ""

    foreach ($k in $keywords) {
        $count = $counts[$k]
        $msg = "$k : $count"

        Write-Host $msg
        $msg | Out-File -LiteralPath $resultFile -Append -Encoding utf8

        $summaryLines += $msg
    }

    $summaryMsg = $summaryLines -join "`n"

    if ($ntfyTopic -ne "") {
        Invoke-RestMethod `
            -Method POST `
            -Uri "https://ntfy.sh/$ntfyTopic" `
            -Body $summaryMsg `
            -ErrorAction SilentlyContinue | Out-Null
    }

    Write-Host "========================================="
    Write-Host "Search Complete"
    Write-Host "Result saved to $resultFile"
    Write-Host "========================================="

    if ($repeat) {
        Write-Host "Sleep $intervalSec sec..."
        Start-Sleep -Seconds $intervalSec
    }

} while ($repeat)