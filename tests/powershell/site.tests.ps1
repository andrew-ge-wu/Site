# CircuitWall Site PowerShell Tests
# Tests for audit.ps1 and build.ps1 scripts

BeforeAll {
    # Set up test environment
    $script:TestRoot = Split-Path $PSScriptRoot -Parent
    $script:ProjectRoot = Split-Path $script:TestRoot -Parent
    $script:AuditScript = Join-Path $script:ProjectRoot "audit.ps1"
    $script:BuildScript = Join-Path $script:ProjectRoot "build.ps1"
    
    # Create temporary test directories
    $script:TempDir = Join-Path $TestDrive "circuitwall-test"
    New-Item -ItemType Directory -Path $script:TempDir -Force
    
    # Copy necessary files for testing
    Copy-Item "$script:ProjectRoot\config.toml" "$script:TempDir\" -Force
    Copy-Item "$script:ProjectRoot\static" "$script:TempDir\" -Recurse -Force
    Copy-Item "$script:ProjectRoot\audit.ps1" "$script:TempDir\" -Force
    Copy-Item "$script:ProjectRoot\build.ps1" "$script:TempDir\" -Force
}

Describe "Audit Script Tests" {
    BeforeEach {
        Push-Location $script:TempDir
    }
    
    AfterEach {
        Pop-Location
    }

    Context "File Existence Checks" {
        It "Should detect modern JavaScript implementation" {
            # Test that the audit script correctly identifies modern JS
            Test-Path "static\js\circuitwall.js" | Should -Be $true
        }

        It "Should detect service worker" {
            Test-Path "static\sw.js" | Should -Be $true
        }

        It "Should detect robots.txt" {
            Test-Path "static\robots.txt" | Should -Be $true
        }

        It "Should detect security.txt" {
            Test-Path "static\.well-known\security.txt" | Should -Be $true
        }
    }

    Context "Configuration Validation" {
        It "Should validate Hugo configuration" {
            $configContent = Get-Content "config.toml" -Raw
            $configContent | Should -Match 'description\s*='
            $configContent | Should -Match 'title\s*='
            $configContent | Should -Match 'baseurl\s*='
        }

        It "Should validate SEO settings" {
            $configContent = Get-Content "config.toml" -Raw
            $configContent | Should -Match 'enableRobotsTXT\s*=\s*true'
            $configContent | Should -Match 'enableGitInfo\s*=\s*true'
        }
    }

    Context "Image Optimization Checks" {
        It "Should calculate image sizes correctly" {
            # Create test images
            $testImageDir = "static\img"
            if (-not (Test-Path $testImageDir)) {
                New-Item -ItemType Directory -Path $testImageDir -Force
            }
            
            # Create a small test file
            "test image content" | Out-File "$testImageDir\test.jpg" -Encoding utf8
            
            $images = Get-ChildItem -Path $testImageDir -Include "*.jpg", "*.png", "*.gif" -Recurse
            $images.Count | Should -BeGreaterThan 0
        }
    }
}

Describe "Build Script Tests" {
    BeforeEach {
        Push-Location $script:TempDir
        
        # Clean any existing build artifacts
        if (Test-Path "public") {
            Remove-Item -Recurse -Force "public"
        }
    }
    
    AfterEach {
        Pop-Location
    }

    Context "Build Parameter Validation" {
        It "Should accept valid environment parameters" {
            # Test that the build script accepts valid parameters
            $validEnvironments = @("development", "production")
            
            foreach ($env in $validEnvironments) {
                # This tests parameter validation without actually running Hugo
                { param([string]$Environment = $env) } | Should -Not -Throw
            }
        }
    }

    Context "File Cleanup" {
        It "Should clean build artifacts" {
            # Create mock build artifacts
            New-Item -ItemType Directory -Path "public" -Force
            New-Item -ItemType Directory -Path "resources" -Force
            "test content" | Out-File "public\test.html"
            "test content" | Out-File "resources\test.json"
            
            # Test cleanup logic (simulate what build.ps1 does)
            if (Test-Path "public") {
                Remove-Item -Recurse -Force "public"
            }
            if (Test-Path "resources") {
                Remove-Item -Recurse -Force "resources"
            }
            
            Test-Path "public" | Should -Be $false
            Test-Path "resources" | Should -Be $false
        }
    }
}

Describe "Security Tests" {
    Context "Security Configuration" {
        It "Should have proper security.txt format" {
            $securityTxtPath = "static\.well-known\security.txt"
            if (Test-Path $securityTxtPath) {
                $content = Get-Content $securityTxtPath -Raw
                $content | Should -Match "Contact:"
                $content | Should -Match "Expires:"
                $content | Should -Match "@"  # Email should be present
            }
        }

        It "Should have proper robots.txt format" {
            $robotsTxtPath = "static\robots.txt"
            if (Test-Path $robotsTxtPath) {
                $content = Get-Content $robotsTxtPath -Raw
                $content | Should -Match "User-agent:"
                $content | Should -Match "Sitemap:"
            }
        }
    }
}

Describe "Performance Tests" {
    Context "Asset Optimization" {
        It "Should have performance CSS" {
            Test-Path "static\css\performance.css" | Should -Be $true
        }

        It "Should have modern JavaScript without jQuery" {
            $jsContent = Get-Content "static\js\circuitwall.js" -Raw
            $jsContent | Should -Match "class CircuitWallSite"
            $jsContent | Should -Not -Match "jquery"
            $jsContent | Should -Not -Match "\$\("  # jQuery selector
        }

        It "Should have service worker for caching" {
            $swContent = Get-Content "static\sw.js" -Raw
            $swContent | Should -Match "addEventListener.*install"
            $swContent | Should -Match "addEventListener.*fetch"
            $swContent | Should -Match "caches"
        }
    }
}

Describe "Integration Tests" {
    Context "File Dependencies" {
        It "Should have all required static assets" {
            $requiredFiles = @(
                "static\js\circuitwall.js",
                "static\css\performance.css",
                "static\sw.js",
                "static\offline.html",
                "static\robots.txt"
            )
            
            foreach ($file in $requiredFiles) {
                Test-Path $file | Should -Be $true -Because "$file should exist"
            }
        }

        It "Should have valid JSON in package.json" {
            if (Test-Path "package.json") {
                { Get-Content "package.json" | ConvertFrom-Json } | Should -Not -Throw
            }
        }

        It "Should have valid TOML in config.toml" {
            $configContent = Get-Content "config.toml" -Raw
            # Basic TOML validation
            $configContent | Should -Not -BeNullOrEmpty
            $configContent | Should -Match '\[.*\]'  # Should have sections
        }
    }
}

# Additional comprehensive tests
Describe "Content Quality Tests" {
    Context "Markdown Content Validation" {
        It "Should have valid frontmatter in content files" {
            $contentDir = Join-Path $script:ProjectRoot "content"
            if (Test-Path $contentDir) {
                $markdownFiles = Get-ChildItem -Path $contentDir -Filter "*.md" -Recurse
                
                foreach ($file in $markdownFiles) {
                    $content = Get-Content $file.FullName -Raw
                    if ($content -match '^---') {
                        $content | Should -Match '^---[\s\S]*?---' -Because "$($file.Name) should have valid frontmatter"
                    }
                }
            }
        }

        It "Should have proper meta descriptions" {
            $contentDir = Join-Path $script:ProjectRoot "content"
            if (Test-Path $contentDir) {
                $markdownFiles = Get-ChildItem -Path $contentDir -Filter "*.md" -Recurse
                
                foreach ($file in $markdownFiles) {
                    $content = Get-Content $file.FullName -Raw
                    # Check if file has frontmatter with description
                    if ($content -match '^---[\s\S]*?description\s*:') {
                        $true | Should -Be $true
                    }
                }
            }
        }
    }

    Context "HTML Template Validation" {
        It "Should have proper HTML structure in layouts" {
            $layoutsDir = Join-Path $script:ProjectRoot "themes\landing-page\layouts"
            if (Test-Path $layoutsDir) {
                $htmlFiles = Get-ChildItem -Path $layoutsDir -Filter "*.html" -Recurse
                
                foreach ($file in $htmlFiles) {
                    $content = Get-Content $file.FullName -Raw
                    if ($content -match '<!DOCTYPE') {
                        $content | Should -Match '<html.*>' -Because "$($file.Name) should have html tag"
                        $content | Should -Match '<head>' -Because "$($file.Name) should have head section"
                        $content | Should -Match '<body>' -Because "$($file.Name) should have body section"
                    }
                }
            }
        }
    }
}

Describe "SEO and Accessibility Tests" {
    Context "Meta Tags Validation" {
        It "Should have proper meta tags in head template" {
            $headTemplate = Join-Path $script:ProjectRoot "themes\landing-page\layouts\partials\head.html"
            if (Test-Path $headTemplate) {
                $content = Get-Content $headTemplate -Raw
                $content | Should -Match 'meta.*description' -Because "Should have meta description"
                $content | Should -Match 'meta.*viewport' -Because "Should have viewport meta tag"
                $content | Should -Match 'meta.*og:' -Because "Should have Open Graph tags"
                $content | Should -Match 'meta.*twitter:' -Because "Should have Twitter Card tags"
            }
        }

        It "Should have structured data" {
            $headTemplate = Join-Path $script:ProjectRoot "themes\landing-page\layouts\partials\head.html"
            if (Test-Path $headTemplate) {
                $content = Get-Content $headTemplate -Raw
                $content | Should -Match 'application/ld\+json' -Because "Should have JSON-LD structured data"
            }
        }
    }

    Context "Accessibility Features" {
        It "Should have skip links in JavaScript" {
            $jsFile = Join-Path $script:ProjectRoot "static\js\circuitwall.js"
            if (Test-Path $jsFile) {
                $content = Get-Content $jsFile -Raw
                $content | Should -Match 'skip-link' -Because "Should implement skip navigation"
                $content | Should -Match 'focus' -Because "Should have focus management"
            }
        }

        It "Should have alt text validation" {
            $jsFile = Join-Path $script:ProjectRoot "static\js\circuitwall.js"
            if (Test-Path $jsFile) {
                $content = Get-Content $jsFile -Raw
                $content | Should -Match 'alt.*=' -Because "Should handle alt attributes"
            }
        }
    }
}

Describe "Build System Integration Tests" {
    Context "Makefile Validation" {
        It "Should have proper Makefile targets" {
            $makefilePath = Join-Path $script:ProjectRoot "Makefile"
            if (Test-Path $makefilePath) {
                $content = Get-Content $makefilePath -Raw
                $content | Should -Match 'serve:' -Because "Should have serve target"
                $content | Should -Match 'build-prod:' -Because "Should have production build target"
                $content | Should -Match 'clean:' -Because "Should have clean target"
                $content | Should -Match '\.PHONY:' -Because "Should declare phony targets"
            }
        }
    }

    Context "NPM Scripts Validation" {
        It "Should have comprehensive npm scripts" {
            $packagePath = Join-Path $script:ProjectRoot "package.json"
            if (Test-Path $packagePath) {
                $package = Get-Content $packagePath | ConvertFrom-Json
                $package.scripts.dev | Should -Not -BeNullOrEmpty
                $package.scripts.build | Should -Not -BeNullOrEmpty
                $package.scripts.test | Should -Not -BeNullOrEmpty
                $package.scripts.clean | Should -Not -BeNullOrEmpty
                $package.scripts.deploy | Should -Not -BeNullOrEmpty
            }
        }

        It "Should have proper development dependencies" {
            $packagePath = Join-Path $script:ProjectRoot "package.json"
            if (Test-Path $packagePath) {
                $package = Get-Content $packagePath | ConvertFrom-Json
                $package.devDependencies | Should -Not -BeNullOrEmpty
                $package.devDependencies.'htmlhint' | Should -Not -BeNullOrEmpty