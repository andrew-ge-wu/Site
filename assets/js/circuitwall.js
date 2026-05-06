// CircuitWall Site - Modern JavaScript (Vanilla JS)
// Replacing jQuery dependencies with modern ES6+ code

class CircuitWallSite {
  constructor() {
    this.init();
  }

  init() {
    this.setupSmoothScrolling();
    this.setupLazyLoading();
    this.setupFormValidation();
    this.setupPerformanceMonitoring();
    this.setupAccessibility();
    this.setupReadingProgress();
    this.setupBackToTop();
    this.setupCodeCopyButtons();
    this.setupShareCopy();
    this.setupTocScrollspy();
    this.setupArchiveFilters();
  }

  // Smooth scrolling navigation
  setupSmoothScrolling() {
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
      anchor.addEventListener('click', (e) => {
        const href = anchor.getAttribute('href');
        if (!href || href === '#' || href.length < 2) return;
        const target = document.querySelector(href);
        if (!target) return; // let the browser navigate (or do nothing) — don't swallow the click
        e.preventDefault();
        const navOffset = 70;
        const top = target.getBoundingClientRect().top + window.pageYOffset - navOffset;
        window.scrollTo({ top, behavior: 'smooth' });
        history.pushState(null, '', href);
      });
    });
  }

  // Lazy loading for images
  setupLazyLoading() {
    if ('IntersectionObserver' in window) {
      const imageObserver = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            const img = entry.target;
            img.src = img.dataset.src;
            img.classList.remove('lazy');
            img.classList.add('loaded');
            observer.unobserve(img);
          }
        });
      });

      document.querySelectorAll('img[data-src]').forEach(img => {
        imageObserver.observe(img);
      });
    }
  }

  // Form validation
  setupFormValidation() {
    const forms = document.querySelectorAll('form');
    forms.forEach(form => {
      form.addEventListener('submit', (e) => {
        if (!this.validateForm(form)) {
          e.preventDefault();
        }
      });
    });
  }

  validateForm(form) {
    const inputs = form.querySelectorAll('input[required], textarea[required]');
    let isValid = true;

    inputs.forEach(input => {
      if (!input.value.trim()) {
        this.showError(input, 'This field is required');
        isValid = false;
      } else if (input.type === 'email' && !this.isValidEmail(input.value)) {
        this.showError(input, 'Please enter a valid email address');
        isValid = false;
      } else {
        this.clearError(input);
      }
    });

    return isValid;
  }

  isValidEmail(email) {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
  }

  showError(input, message) {
    const errorElement = input.parentNode.querySelector('.error-message');
    if (errorElement) {
      errorElement.textContent = message;
    } else {
      const error = document.createElement('div');
      error.className = 'error-message';
      error.textContent = message;
      error.style.color = '#dc3545';
      error.style.fontSize = '0.875rem';
      error.style.marginTop = '0.25rem';
      input.parentNode.appendChild(error);
    }
    input.classList.add('error');
  }

  clearError(input) {
    const errorElement = input.parentNode.querySelector('.error-message');
    if (errorElement) {
      errorElement.remove();
    }
    input.classList.remove('error');
  }

  // Performance monitoring
  setupPerformanceMonitoring() {
    if ('performance' in window) {
      window.addEventListener('load', () => {
        setTimeout(() => {
          const perfData = performance.getEntriesByType('navigation')[0];
          console.log(`Page load time: ${perfData.loadEventEnd - perfData.loadEventStart}ms`);
          
          // Send to analytics if available
          if (typeof gtag !== 'undefined') {
            gtag('event', 'page_load_time', {
              custom_parameter: perfData.loadEventEnd - perfData.loadEventStart
            });
          }
        }, 0);
      });
    }
  }

  // Accessibility enhancements
  setupAccessibility() {
    // Add skip to main content link
    const skipLink = document.createElement('a');
    skipLink.href = '#main';
    skipLink.className = 'skip-link';
    skipLink.textContent = 'Skip to main content';
    document.body.insertBefore(skipLink, document.body.firstChild);

    // Keyboard navigation for mobile menu
    const mobileMenuToggle = document.querySelector('.navbar-toggle');
    if (mobileMenuToggle) {
      mobileMenuToggle.addEventListener('keydown', (e) => {
        if (e.key === 'Enter' || e.key === ' ') {
          e.preventDefault();
          mobileMenuToggle.click();
        }
      });
    }

    // Focus management for modal dialogs
    this.setupFocusManagement();
  }

  setupFocusManagement() {
    const focusableElements = 'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])';
    
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Tab') {
        const focusableNodes = document.querySelectorAll(focusableElements);
        const focusedItemIndex = Array.from(focusableNodes).indexOf(document.activeElement);

        if (e.shiftKey) {
          if (focusedItemIndex === 0) {
            focusableNodes[focusableNodes.length - 1].focus();
            e.preventDefault();
          }
        } else {
          if (focusedItemIndex === focusableNodes.length - 1) {
            focusableNodes[0].focus();
            e.preventDefault();
          }
        }
      }
    });
  }

  // Service worker registration for offline support
  registerServiceWorker() {
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker.register('/sw.js')
        .then(registration => {
          console.log('Service Worker registered successfully');
        })
        .catch(error => {
          console.log('Service Worker registration failed');
        });
    }
  }

  // Reading-progress bar
  setupReadingProgress() {
    const bar = document.querySelector('[data-reading-progress-bar]');
    const article = document.querySelector('[data-post-body]');
    if (!bar || !article) return;
    const update = () => {
      const rect = article.getBoundingClientRect();
      const total = rect.height - window.innerHeight + rect.top + window.scrollY;
      const start = rect.top + window.scrollY - 80;
      const progress = Math.min(1, Math.max(0, (window.scrollY - start) / Math.max(1, article.offsetHeight - window.innerHeight + 80)));
      bar.style.width = (progress * 100).toFixed(2) + '%';
    };
    window.addEventListener('scroll', update, { passive: true });
    window.addEventListener('resize', update);
    update();
  }

  // Back-to-top button
  setupBackToTop() {
    const btn = document.querySelector('[data-back-to-top]');
    if (!btn) return;
    btn.removeAttribute('hidden');
    const onScroll = () => {
      if (window.scrollY > 400) btn.classList.add('is-visible');
      else btn.classList.remove('is-visible');
    };
    btn.addEventListener('click', () => window.scrollTo({ top: 0, behavior: 'smooth' }));
    window.addEventListener('scroll', onScroll, { passive: true });
    onScroll();
  }

  // Copy buttons on code blocks
  setupCodeCopyButtons() {
    document.querySelectorAll('.post-body pre').forEach(pre => {
      if (pre.querySelector('.code-copy-btn')) return;
      const btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'code-copy-btn';
      btn.textContent = 'Copy';
      btn.addEventListener('click', async () => {
        const code = pre.querySelector('code')?.innerText ?? pre.innerText;
        try {
          await navigator.clipboard.writeText(code);
          btn.textContent = 'Copied';
          btn.classList.add('copied');
          setTimeout(() => { btn.textContent = 'Copy'; btn.classList.remove('copied'); }, 1500);
        } catch (e) { /* ignore */ }
      });
      pre.appendChild(btn);
    });
  }

  // "Copy link" share button on posts
  setupShareCopy() {
    const btn = document.querySelector('[data-copy-link]');
    if (!btn) return;
    btn.addEventListener('click', async () => {
      try {
        await navigator.clipboard.writeText(window.location.href);
        btn.classList.add('is-copied');
        setTimeout(() => btn.classList.remove('is-copied'), 1500);
      } catch (e) { /* ignore */ }
    });
  }

  // Highlight active TOC item while scrolling
  setupTocScrollspy() {
    const toc = document.querySelector('[data-post-toc]');
    if (!toc) return;
    const links = Array.from(toc.querySelectorAll('a[href^="#"]'));
    if (!links.length) return;
    const headings = links
      .map(a => document.getElementById(decodeURIComponent(a.getAttribute('href').slice(1))))
      .filter(Boolean);
    if (!headings.length) return;
    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (!entry.isIntersecting) return;
        links.forEach(a => a.classList.remove('is-active'));
        const id = entry.target.id;
        const active = toc.querySelector(`a[href="#${CSS.escape(id)}"]`);
        if (active) active.classList.add('is-active');
      });
    }, { rootMargin: '-90px 0px -70% 0px', threshold: 0 });
    headings.forEach(h => observer.observe(h));
  }

  // Tag filter chips on archive page
  setupArchiveFilters() {
    const wrap = document.querySelector('[data-archive-filters]');
    const grid = document.querySelector('[data-archive-grid]');
    const empty = document.querySelector('[data-archive-empty]');
    if (!wrap || !grid) return;
    const cards = Array.from(grid.querySelectorAll('[data-tags]'));
    wrap.addEventListener('click', (e) => {
      const btn = e.target.closest('[data-filter]');
      if (!btn) return;
      wrap.querySelectorAll('.archive-chip').forEach(b => b.classList.remove('is-active'));
      btn.classList.add('is-active');
      const filter = btn.dataset.filter;
      let visible = 0;
      cards.forEach(card => {
        const tags = (card.dataset.tags || '').split(' ').filter(Boolean);
        const show = filter === '*' || tags.includes(filter);
        card.style.display = show ? '' : 'none';
        if (show) visible++;
      });
      if (empty) empty.hidden = visible !== 0;
    });
  }
}

// Initialize when DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => {
    new CircuitWallSite();
  });
} else {
  new CircuitWallSite();
}

// Export for testing
if (typeof module !== 'undefined' && module.exports) {
  module.exports = CircuitWallSite;
}
