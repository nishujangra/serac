// Authentication utility functions

// Check if user is authenticated
function isAuthenticated() {
    const token = localStorage.getItem('authToken');
    return token !== null && token !== undefined;
}

// Get authentication token
function getAuthToken() {
    return localStorage.getItem('authToken');
}

// Set authentication token
function setAuthToken(token) {
    localStorage.setItem('authToken', token);
}

// Remove authentication token (logout)
function removeAuthToken() {
    localStorage.removeItem('authToken');
}

// Logout user
function logout() {
    removeAuthToken();
    window.location.href = '/auth/login';
}

// Add authentication header to fetch requests
function addAuthHeader(headers = {}) {
    const token = getAuthToken();
    if (token) {
        headers['Authorization'] = `Bearer ${token}`;
    }
    return headers;
}

// Make authenticated API request
async function authenticatedFetch(url, options = {}) {
    const headers = addAuthHeader(options.headers || {});
    
    const response = await fetch(url, {
        ...options,
        headers: {
            'Content-Type': 'application/json',
            ...headers
        }
    });

    // If unauthorized, redirect to login
    if (response.status === 401) {
        logout();
        return null;
    }

    return response;
}

// Check token validity
async function validateToken() {
    try {
        const response = await authenticatedFetch('/api/auth/validate');
        return response && response.ok;
    } catch (error) {
        console.error('Token validation error:', error);
        return false;
    }
}

// Auto-logout if token is invalid
async function checkAuthStatus() {
    if (isAuthenticated()) {
        const isValid = await validateToken();
        if (!isValid) {
            logout();
        }
    }
}

// Initialize auth check on page load
document.addEventListener('DOMContentLoaded', function() {
    // Check auth status every 5 minutes
    setInterval(checkAuthStatus, 5 * 60 * 1000);
    
    // Check immediately on page load
    checkAuthStatus();
});

// Export functions for use in other modules
window.AuthUtils = {
    isAuthenticated,
    getAuthToken,
    setAuthToken,
    removeAuthToken,
    logout,
    addAuthHeader,
    authenticatedFetch,
    validateToken,
    checkAuthStatus
}; 