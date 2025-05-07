$files = Get-ChildItem -Path lib -Recurse -Filter *.dart | Where-Object { $_.FullName -notlike '*app_theme*' }

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    
    # Fix helper methods that were incorrectly changed to AppColors instead of AppThemeHelpers
    $content = $content -replace 'AppColors\.(get[a-zA-Z]+?)\(', 'AppThemeHelpers.$1('
    
    # Fix button styles that were incorrectly changed to AppColors instead of AppButtonStyles
    $content = $content -replace 'AppColors\.(get.*ButtonStyle)\(', 'AppButtonStyles.$1('
    
    # Fix any remaining AppTheme references
    $content = $content -replace 'AppTheme\.accentGreen', 'AppColors.accentGreen'
    $content = $content -replace 'AppTheme\.accentGreenDark', 'AppColors.accentGreenDark'
    
    Set-Content -Path $file.FullName -Value $content
    Write-Host "Updated: $($file.FullName)"
}

Write-Host "All files have been updated successfully!" 