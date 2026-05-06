# CircuitWall Consultancy Website

[![Netlify Status](https://api.netlify.com/api/v1/badges/a74af2d7-041f-45de-9272-9abbb69db981/deploy-status)](https://app.netlify.com/sites/circuitwall/deploys)
[![Performance](https://img.shields.io/badge/Performance-Optimized-green)](https://circuitwall.net)
[![Security](https://img.shields.io/badge/Security-Enhanced-blue)](https://circuitwall.net)

Professional consulting website for Java, Spring, JVM performance tuning, big data, and machine learning services by Andrew Wu in Stockholm, Sweden.

## 🚀 Recent Optimizations (2025)

This website has been significantly optimized for performance, security, and modern web standards:

### Performance Enhancements
- ✅ **Modern JavaScript**: Replaced jQuery 1.11.0 with vanilla ES6+ JavaScript
- ✅ **Service Worker**: Offline support and intelligent caching
- ✅ **Image Optimization**: Lazy loading and responsive images
- ✅ **CSS Optimization**: Performance-focused stylesheets
- ✅ **Build Pipeline**: Minification and asset optimization
- ✅ **Core Web Vitals**: Optimized for Google's performance metrics

### Security Improvements
- ✅ **Modern Dependencies**: Updated all outdated libraries
- ✅ **Security Headers**: CSP, HSTS, and other protective headers
- ✅ **Robots.txt & Security.txt**: Proper crawling and security policies
- ✅ **HTTPS Enforcement**: Secure connections only

### SEO & Accessibility
- ✅ **Meta Tags**: Comprehensive Open Graph and Twitter Card support
- ✅ **Structured Data**: JSON-LD for better search engine understanding
- ✅ **Accessibility**: WCAG compliant with focus management
- ✅ **Progressive Enhancement**: Works without JavaScript

## 🛠 Technology Stack

- **Static Site Generator**: Hugo v0.161.1
- **Styling**: Bootstrap 4 + Custom CSS
- **JavaScript**: Vanilla ES6+ (No jQuery dependency)
- **Deployment**: Netlify with automatic builds
- **Performance**: Service Worker + Offline Support

## 📁 Project Structure

```
├── config.toml              # Hugo configuration with SEO optimizations
├── package.json             # Node.js dependencies and scripts
├── build.ps1               # Optimized build script for Windows
├── audit.ps1               # Security & performance audit tool
├── content/                # Markdown content
│   ├── about/
│   ├── posts/
│   └── services/
├── layouts/                # Custom Hugo layouts
├── static/                 # Static assets
│   ├── css/performance.css # Modern CSS optimizations
│   ├── js/circuitwall.js  # Modern JavaScript
│   ├── sw.js              # Service Worker
│   ├── offline.html       # Offline page
│   └── robots.txt         # SEO configuration
└── themes/landing-page/    # Custom Hugo theme
```

## 🚀 Quick Start

### Prerequisites
- Hugo Extended v0.161.1+
- Node.js 20+ (optional, for npm scripts)
- PowerShell (Windows) or Bash (Linux/Mac)

### Development
```powershell
# Clone the repository
git clone https://github.com/CircuitWall/site.git
cd site

# Install dependencies (optional)
npm install

# Start development server
hugo serve --buildDrafts --buildFuture
# or
npm run dev
```

### Production Build
```powershell
# Build for production
.\build.ps1 -Environment production -Optimize
# or
npm run build

# Run security & performance audit
.\audit.ps1 -All
```

## 📊 Performance Metrics

Current performance optimizations achieve:
- **Lighthouse Score**: 95+ (Performance, Accessibility, Best Practices, SEO)
- **First Contentful Paint**: < 1.5s
- **Largest Contentful Paint**: < 2.5s
- **Cumulative Layout Shift**: < 0.1
- **Total Bundle Size**: < 5MB

## 🔧 Development Scripts

```powershell
# Development
npm run dev                 # Start dev server
npm run build:dev          # Build for development

# Production
npm run build              # Production build
npm run serve:prod         # Test production build locally

# Maintenance
npm run clean              # Clean build artifacts
npm run lint               # Lint HTML files
npm run optimize           # Optimize images
npm run test               # Run all tests
```

## 🔒 Security Features

- **Content Security Policy**: Prevents XSS attacks
- **HTTPS Only**: Secure connections enforced
- **Security Headers**: X-Frame-Options, X-Content-Type-Options, etc.
- **Dependency Scanning**: No known vulnerabilities
- **Responsible Disclosure**: Security.txt implementation

## 📈 SEO Optimizations

- **Structured Data**: Schema.org markup for better search visibility
- **Open Graph**: Optimized social media sharing
- **Meta Tags**: Comprehensive meta descriptions and keywords
- **Sitemap**: Automatically generated
- **Robots.txt**: Proper crawling instructions
- **Canonical URLs**: Preventing duplicate content issues

## 🌐 Browser Support

- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+
- Mobile browsers (iOS Safari, Chrome Mobile)

## 📝 Content Management

### Adding New Blog Posts
```markdown
---
title: "Your Post Title"
date: "2025-06-02T10:00:00+02:00"
description: "SEO-friendly description"
img: "featured-image.jpg"
draft: false
author: "Andrew Wu"
tags: ["tag1", "tag2"]
categories: ["category"]
---

Your content here...
```

### Adding New Services
Create a new file in `content/services/` with proper frontmatter and content.

## 🚀 Deployment

Automatic deployment via Netlify:
1. Push to main branch
2. Netlify builds automatically
3. Deploy to https://circuitwall.net

Manual deployment:
```powershell
# Build and deploy
.\build.ps1 -Environment production -Optimize
netlify deploy --prod --dir=public
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run the audit: `.\audit.ps1 -All`
5. Submit a pull request

## 📞 Contact

- **Email**: contact@circuitwall.net
- **LinkedIn**: [Andrew Wu](https://se.linkedin.com/in/andrew-wu-ba92b921)
- **GitHub**: [CircuitWall](https://github.com/CircuitWall)

---

© 2025 CircuitWall Consultancy. Built with ❤️ using Hugo and modern web technologies.
