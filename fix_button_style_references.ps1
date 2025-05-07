$files = Get-ChildItem -Path lib -Recurse -Filter *.dart | Where-Object { $_.FullName -notlike '*app_theme*' }

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    
    # Fix button styles that were incorrectly changed to AppThemeHelpers instead of AppButtonStyles
    $content = $content -replace 'AppThemeHelpers\.(get.*ButtonStyle)\(', 'AppButtonStyles.$1('
    
    Set-Content -Path $file.FullName -Value $content
    Write-Host "Updated: $($file.FullName)"
}

Write-Host "All files have been updated successfully!" 