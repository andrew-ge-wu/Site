# CircuitWall Site Security & Performance Audit Script

param(
    [switch]$Security = $false,
    [switch]$Performance = $false,
    [switch]$All = $false
)

if ($All) {
    $Security = $true
    $Performance = $true
}

Write-Host "CircuitWall Site Audit Tool" -ForegroundColor Green
Write-Host "===========================" -ForegroundColor Green

function Test-SecurityHeaders {
    Write-Host "`nSecurity Headers Check:" -ForegroundColor Yellow
    
    $headers = @(
        "Content-Security-Policy",
        "X-Frame-Options", 
        "X-Content-Type-Options",
        "Referrer-Policy",
        "Permissions-Policy"
    )
    
    try {
        $response = Invoke-WebRequest -Uri "https://circuitwall.net" -Method Head -ErrorAction SilentlyContinue
        
        foreach ($header in $headers) {
            if ($response.Headers[$header]) {
                Write-Host "  ✓ $header: Present" -ForegroundColor Green
            } else {
                Write-Host "  ✗ $header: Missing" -ForegroundColor Red
            }
        }
    }
    catch {
        Write-Host "  Could not check live site headers" -ForegroundColor Yellow
    }
}

function Test-ImageOptimization {
    Write-Host "`nImage Optimization Check:" -ForegroundColor Yellow
    
    $imageDir = "static/img"
    if (Test-Path $imageDir) {
        $images = Get-ChildItem -Path $imageDir -Include "*.jpg", "*.png", "*.gif" -Recurse
        
        foreach ($image in $images) {
            $sizeKB = [math]::Round($image.Length / 1KB, 1)
            $color = if ($sizeKB -gt 500) { "Red" } elseif ($sizeKB -gt 200) { "Yellow" } else { "Green" }
            Write-Host "  $($image.Name): ${sizeKB}KB" -ForegroundColor $color
        }
        
        $totalSizeMB = [math]::Round(($images | Measure-Object Length -Sum).Sum / 1MB, 2)
        Write-Host "  Total image size: ${totalSizeMB}MB" -ForegroundColor Cyan
    }
}

function Test-CodeQuality {
    Write-Host "`nCode Quality Check:" -ForegroundColor Yellow
    
    # Check for outdated dependencies
    if (Test-Path "themes/landing-page/static/js/jquery-1.11.0.js") {
        Write-Host "  ✗ Outdated jQuery 1.11.0 detected" -ForegroundColor Red
    } else {
        Write-Host "  ✓ No outdated jQuery found" -ForegroundColor Green
    }
    
    # Check for modern JavaScript
    if (Test-Path "static/js/circuitwall.js") {
        Write-Host "  ✓ Modern JavaScript implementation found" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Modern JavaScript missing" -ForegroundColor Red
    }
    
    # Check for service worker
    if (Test-Path "static/sw.js") {
        Write-Host "  ✓ Service Worker implemented" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Service Worker missing" -ForegroundColor Red
    }
}

function Test-SEOOptimization {
    Write-Host "`nSEO Optimization Check:" -ForegroundColor Yellow
    
    $configContent = Get-Content "config.toml" -Raw
    
    # Check for meta description
    if ($configContent -match 'description\s*=') {
        Write-Host "  ✓ Meta description configured" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Meta description missing" -ForegroundColor Red
    }
    
    # Check for robots.txt
    if (Test-Path "static/robots.txt") {
        Write-Host "  ✓ robots.txt present" -ForegroundColor Green
    } else {
        Write-Host "  ✗ robots.txt missing" -ForegroundColor Red
    }
    
    # Check for sitemap
    if (Test-Path "public/sitemap.xml") {
        Write-Host "  ✓ Sitemap generated" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Sitemap missing (run hugo build)" -ForegroundColor Yellow
    }
}

function Test-PerformanceMetrics {
    Write-Host "`nPerformance Metrics:" -ForegroundColor Yellow
    
    # Check build size
    if (Test-Path "public") {
        $publicSize = (Get-ChildItem -Path "public" -Recurse | Measure-Object -Property Length -Sum).Sum
        $publicSizeMB = [math]::Round($publicSize / 1MB, 2)
        
        $color = if ($publicSizeMB -gt 10) { "Red" } elseif ($publicSizeMB -gt 5) { "Yellow" } else { "Green" }
        Write-Host "  Build size: ${publicSizeMB}MB" -ForegroundColor $color
    }
    
    # Check CSS/JS minification
    $cssFiles = Get-ChildItem -Path "public/css" -Include "*.css" -Exclude "*.min.css" -ErrorAction SilentlyContinue
    $jsFiles = Get-ChildItem -Path "public/js" -Include "*.js" -Exclude "*.min.js" -ErrorAction SilentlyContinue
    
    if ($cssFiles.Count -eq 0) {
        Write-Host "  ✓ CSS files appear to be minified" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Non-minified CSS files found" -ForegroundColor Red
    }
}

function Show-Recommendations {
    Write-Host "`nRecommendations:" -ForegroundColor Cyan
    Write-Host "=================" -ForegroundColor Cyan
    
    Write-Host "1. Enable HTTPS and security headers in Netlify" -ForegroundColor White
    Write-Host "2. Optimize images using WebP format" -ForegroundColor White
    Write-Host "3. Implement lazy loading for images" -ForegroundColor White
    Write-Host "4. Add Content Security Policy" -ForegroundColor White
    Write-Host "5. Consider implementing Progressive Web App features" -ForegroundColor White
    Write-Host "6. Monitor Core Web Vitals using Google PageSpeed Insights" -ForegroundColor White
    Write-Host "7. Set up monitoring with tools like Lighthouse CI" -ForegroundColor White
}

# Run audits based on parameters
if ($Security) {
    Test-SecurityHeaders
    Test-CodeQuality
}

if ($Performance) {
    Test-ImageOptimization
    Test-PerformanceMetrics
    Test-SEOOptimization
}

if (-not $Security -and -not $Performance) {
    Write-Host "Use -Security, -Performance, or -All flags to run specific audits" -ForegroundColor Yellow
    Write-Host "Example: .\audit.ps1 -All" -ForegroundColor Gray
}

Show-Recommendations

Write-Host "`nAudit complete!" -ForegroundColor Green
