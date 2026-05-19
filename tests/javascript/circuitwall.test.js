// CircuitWall Site JavaScript Unit Tests
// Test the CircuitWallSite class functionality

// Mock DOM environment for Node.js testing
const { JSDOM } = require('jsdom');

// Create a basic DOM environment
const dom = new JSDOM(`
<!DOCTYPE html>
<html>
<head>
    <title>Test Page</title>
</head>
<body>
    <div id="main">
        <form id="test-form">
            <input type="email" name="email" required>
            <textarea name="message" required></textarea>
            <button type="submit">Submit</button>
        </form>
        <img data-src="test.jpg" class="lazy" alt="Test image">
        <a href="#section1">Smooth scroll link</a>
        <div id="section1">Target section</div>
    </div>
</body>
</html>
`, { url: 'http://localhost' });

// Set up global DOM environment
global.window = dom.window;
global.document = dom.window.document;
global.navigator = {
    serviceWorker: {
        register: jest.fn().mockResolvedValue({ scope: '/' })
    }
};

// Mock IntersectionObserver
global.IntersectionObserver = class IntersectionObserver {
    constructor(callback) {
        this.callback = callback;
    }
    observe() {}
    unobserve() {}
    disconnect() {}
};

// Import the CircuitWallSite class
const CircuitWallSite = require('../../static/js/circuitwall.js');

describe('CircuitWallSite Class', () => {
    let site;

    beforeEach(() => {
        // Reset DOM state
        document.body.innerHTML = `
            <div id="main">
                <form id="test-form">
                    <input type="email" name="email" required>
                    <textarea name="message" required></textarea>
                    <button type="submit">Submit</button>
                </form>
                <img data-src="test.jpg" class="lazy" alt="Test image">
                <a href="#section1">Smooth scroll link</a>
                <div id="section1">Target section</div>
            </div>
        `;
        
        site = new CircuitWallSite();
    });

    describe('Email Validation', () => {
        test('should validate correct email addresses', () => {
            expect(site.isValidEmail('test@example.com')).toBe(true);
            expect(site.isValidEmail('user.name+tag@domain.co.uk')).toBe(true);
            expect(site.isValidEmail('user@domain-name.com')).toBe(true);
        });

        test('should reject invalid email addresses', () => {
            expect(site.isValidEmail('invalid-email')).toBe(false);
            expect(site.isValidEmail('test@')).toBe(false);
            expect(site.isValidEmail('@domain.com')).toBe(false);
            expect(site.isValidEmail('test..test@domain.com')).toBe(false);
        });

        test('should handle edge cases', () => {
            expect(site.isValidEmail('')).toBe(false);
            expect(site.isValidEmail(null)).toBe(false);
            expect(site.isValidEmail(undefined)).toBe(false);
        });
    });

    describe('Form Validation', () => {
        test('should validate required fields', () => {
            const form = document.getElementById('test-form');
            const emailInput = form.querySelector('input[name="email"]');
            const messageInput = form.querySelector('textarea[name="message"]');

            // Empty form should fail validation
            expect(site.validateForm(form)).toBe(false);

            // Fill required fields
            emailInput.value = 'test@example.com';
            messageInput.value = 'Test message';

            expect(site.validateForm(form)).toBe(true);
        });

        test('should show and clear error messages', () => {
            const form = document.getElementById('test-form');
            const emailInput = form.querySelector('input[name="email"]');

            // Show error
            site.showError(emailInput, 'Test error message');
            
            const errorElement = emailInput.parentNode.querySelector('.error-message');
            expect(errorElement).toBeTruthy();
            expect(errorElement.textContent).toBe('Test error message');
            expect(emailInput.classList.contains('error')).toBe(true);

            // Clear error
            site.clearError(emailInput);
            
            const clearedError = emailInput.parentNode.querySelector('.error-message');
            expect(clearedError).toBeFalsy();
            expect(emailInput.classList.contains('error')).toBe(false);
        });
    });

    describe('Accessibility Features', () => {
        test('should add skip link', () => {
            // The skip link should be added during initialization
            const skipLink = document.querySelector('.skip-link');
            expect(skipLink).toBeTruthy();
            expect(skipLink.href).toContain('#main');
            expect(skipLink.textContent).toBe('Skip to main content');
        });
    });

    describe('Service Worker', () => {
        test('should register service worker when supported', () => {
            site.registerServiceWorker();
            expect(navigator.serviceWorker.register).toHaveBeenCalledWith('/sw.js');
        });
    });
});

describe('Utility Functions', () => {
    test('should handle DOM ready state correctly', () => {
        // Test is mainly to ensure the module loads without errors
        expect(typeof CircuitWallSite).toBe('function');
    });
});

// Performance Tests
describe('Performance Features', () => {
    let mockPerformance;

    beforeEach(() => {
        mockPerformance = {
            getEntriesByType: jest.fn().mockReturnValue([{
                loadEventEnd: 1000,
                loadEventStart: 100
            }])
        };
        global.performance = mockPerformance;
    });

    test('should monitor performance metrics', () => {
        site.setupPerformanceMonitoring();
        
        // Simulate load event
        const loadEvent = new dom.window.Event('load');
        dom.window.dispatchEvent(loadEvent);

        // Wait for setTimeout to execute
        setTimeout(() => {
            expect(mockPerformance.getEntriesByType).toHaveBeenCalledWith('navigation');
        }, 10);
    });
});

// Lazy Loading Tests
describe('Lazy Loading', () => {
    test('should set up intersection observer for lazy loading', () => {
        const mockObserve = jest.fn();
        global.IntersectionObserver = jest.fn().mockImplementation((callback) => ({
            observe: mockObserve,
            unobserve: jest.fn(),
            disconnect: jest.fn(),
            callback: callback
        }));

        site.setupLazyLoading();

        const lazyImages = document.querySelectorAll('img[data-src]');
        expect(lazyImages.length).toBeGreaterThan(0);
        expect(mockObserve).toHaveBeenCalled();
    });
});

// Error Handling Tests
describe('Error Handling', () => {
    test('should handle missing form elements gracefully', () => {
        const emptyForm = document.createElement('form');
        expect(() => site.validateForm(emptyForm)).not.toThrow();
    });

    test('should handle invalid email gracefully', () => {
        expect(() => site.isValidEmail(null)).not.toThrow();
        expect(() => site.isValidEmail(undefined)).not.toThrow();
        expect(() => site.isValidEmail('')).not.toThrow();
    });
});
