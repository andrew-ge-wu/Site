
# Define variables
HUGO_VERSION := 0.161.1
HUGO_BINARY := hugo_extended_$(HUGO_VERSION)_linux-amd64.deb

# Install Hugo (Linux)
install:
	wget https://github.com/gohugoio/hugo/releases/download/v$(HUGO_VERSION)/$(HUGO_BINARY)
	sudo dpkg -i $(HUGO_BINARY)
	rm $(HUGO_BINARY)

# Development server with live reload
serve:
	hugo serve --buildDrafts --buildFuture --disableFastRender

# Production build
build-prod:
	powershell -ExecutionPolicy Bypass -File build.ps1 -Environment production -Optimize

# Development build
build-dev:
	powershell -ExecutionPolicy Bypass -File build.ps1 -Environment development

# Clean build artifacts
clean:
	powershell -Command "if (Test-Path 'public') { Remove-Item -Recurse -Force 'public' }"
	powershell -Command "if (Test-Path 'resources') { Remove-Item -Recurse -Force 'resources' }"

# Deploy to Netlify (requires Netlify CLI)
deploy:
	netlify deploy --prod --dir=public

# Local testing
test:
	hugo serve --environment production --disableLiveReload

.PHONY: install serve build-prod build-dev clean deploy test