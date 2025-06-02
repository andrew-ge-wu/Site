# CircuitWall Site Build & Deploy Script

param(
    [string]$Environment = "development",
    [switch]$Optimize = $false
)

Write-Host "Building CircuitWall Site for $Environment environment..." -ForegroundColor Green

# Clean previous build
if (Test-Path "public") {
    Remove-Item -Recurse -Force "public"
}

# Set Hugo environment
$env:HUGO_ENV = $Environment

# Build based on environment
if ($Environment -eq "production") {
    Write-Host "Building for production with optimizations..." -ForegroundColor Yellow
    hugo --gc --minify --enableGitInfo
} else {
    Write-Host "Building for development..." -ForegroundColor Yellow
    hugo --buildDrafts --buildFuture
}

# Optional post-processing
if ($Optimize) {
    Write-Host "Running additional optimizations..." -ForegroundColor Yellow
    
    # Remove development artifacts
    Get-ChildItem -Path "public" -Recurse -Name "*.map" | Remove-Item -Force
    
    # Compress images (requires ImageMagick)
    if (Get-Command "magick" -ErrorAction SilentlyContinue) {
        Write-Host "Optimizing images..." -ForegroundColor Cyan
        Get-ChildItem -Path "public\img" -Include "*.jpg", "*.png" -Recurse | ForEach-Object {
            $originalSize = $_.Length
            & magick $_.FullName -quality 85 -strip $_.FullName
            $newSize = (Get-Item $_.FullName).Length
            $savings = [math]::Round((($originalSize - $newSize) / $originalSize) * 100, 1)
            Write-Host "  Optimized $($_.Name): $savings% smaller" -ForegroundColor Gray
        }
    }
}

Write-Host "Build completed successfully!" -ForegroundColor Green

# Display build stats
$publicSize = (Get-ChildItem -Path "public" -Recurse | Measure-Object -Property Length -Sum).Sum
$publicSizeMB = [math]::Round($publicSize / 1MB, 2)
Write-Host "Total build size: $publicSizeMB MB" -ForegroundColor Cyan
