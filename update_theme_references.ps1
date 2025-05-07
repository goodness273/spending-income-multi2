$files = Get-ChildItem -Path lib -Recurse -Filter *.dart | Where-Object { $_.FullName -notlike '*app_theme*' }

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    
    # Update color references
    $content = $content -replace 'AppTheme\.([a-zA-Z]+)(?!\()', 'AppColors.$1'
    
    # Update helper methods
    $content = $content -replace 'AppTheme\.(get[a-zA-Z]+?)\(', 'AppThemeHelpers.$1('
    
    # Update button styles
    $content = $content -replace 'AppTheme\.(get.*ButtonStyle)\(', 'AppButtonStyles.$1('
    
    # Update theme building methods
    $content = $content -replace 'AppTheme\.(build.*Theme)\(', 'AppThemeBuilder.$1('
    
    # Update text styles
    $content = $content -replace 'AppTheme\.([a-zA-Z]+Style)', 'AppTextStyles.$1'
    
    # Update input decoration method
    $content = $content -replace 'AppTheme\.getInputDecoration\(', 'AppThemeHelpers.getInputDecoration('
    
    # Update card decoration method
    $content = $content -replace 'AppTheme\.getCardDecoration\(', 'AppThemeHelpers.getCardDecoration('
    
    Set-Content -Path $file.FullName -Value $content
    Write-Host "Updated: $($file.FullName)"
}

Write-Host "All files have been updated successfully!" 