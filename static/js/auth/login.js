// Login form functionality
document.addEventListener('DOMContentLoaded', function() {
    const loginForm = document.getElementById('loginForm');
    const submitButton = document.querySelector('button[type="submit"]');
    const errorContainer = document.getElementById('errorContainer');
    const successContainer = document.getElementById('successContainer');

    // Form validation functions
    function validateUsername(username) {
        if (!username || username.trim().length < 3) {
            return 'Username must be at least 3 characters long';
        }
        return null;
    }

    function validatePassword(password) {
        if (!password || password.length < 1) {
            return 'Password is required';
        }
        return null;
    }

    // Show error message
    function showError(message) {
        if (errorContainer) {
            errorContainer.textContent = message;
            errorContainer.classList.remove('hidden');
            errorContainer.classList.add('block');
        } else {
            // Create error container if it doesn't exist
            const errorDiv = document.createElement('div');
            errorDiv.id = 'errorContainer';
            errorDiv.className = 'bg-red-500 text-white p-3 rounded-md mb-4 text-sm';
            errorDiv.textContent = message;
            loginForm.insertBefore(errorDiv, loginForm.firstChild);
        }
        
        if (successContainer) {
            successContainer.classList.add('hidden');
        }
    }

    // Show success message
    function showSuccess(message) {
        if (successContainer) {
            successContainer.textContent = message;
            successContainer.classList.remove('hidden');
            successContainer.classList.add('block');
        } else {
            // Create success container if it doesn't exist
            const successDiv = document.createElement('div');
            successDiv.id = 'successContainer';
            successDiv.className = 'bg-green-500 text-white p-3 rounded-md mb-4 text-sm';
            successDiv.textContent = message;
            loginForm.insertBefore(successDiv, loginForm.firstChild);
        }
        
        if (errorContainer) {
            errorContainer.classList.add('hidden');
        }
    }

    // Hide messages
    function hideMessages() {
        if (errorContainer) {
            errorContainer.classList.add('hidden');
        }
        if (successContainer) {
            successContainer.classList.add('hidden');
        }
    }

    // Update button state
    function setButtonState(loading) {
        if (submitButton) {
            if (loading) {
                submitButton.disabled = true;
                submitButton.textContent = 'Signing In...';
                submitButton.classList.add('opacity-50', 'cursor-not-allowed');
            } else {
                submitButton.disabled = false;
                submitButton.textContent = 'Sign In';
                submitButton.classList.remove('opacity-50', 'cursor-not-allowed');
            }
        }
    }

    // Real-time validation
    function setupRealTimeValidation() {
        const inputs = loginForm.querySelectorAll('input');
        
        inputs.forEach(input => {
            input.addEventListener('blur', function() {
                validateField(input);
            });
            
            input.addEventListener('input', function() {
                // Clear error styling on input
                input.classList.remove('border-red-500');
                input.classList.add('border-gray-700');
            });
        });
    }

    // Validate individual field
    function validateField(field) {
        const value = field.value.trim();
        let error = null;

        switch (field.name) {
            case 'username':
                error = validateUsername(value);
                break;
            case 'password':
                error = validatePassword(value);
                break;
        }

        if (error) {
            field.classList.remove('border-gray-700');
            field.classList.add('border-red-500');
            showError(error);
        } else {
            field.classList.remove('border-red-500');
            field.classList.add('border-gray-700');
            hideMessages();
        }

        return !error;
    }

    // Validate entire form
    function validateForm() {
        const formData = new FormData(loginForm);
        const data = Object.fromEntries(formData);
        
        const validations = [
            { field: 'username', value: data.username, validator: validateUsername },
            { field: 'password', value: data.password, validator: validatePassword }
        ];

        for (const validation of validations) {
            const error = validation.validator(validation.value);
            if (error) {
                const field = document.querySelector(`[name="${validation.field}"]`);
                if (field) {
                    field.classList.remove('border-gray-700');
                    field.classList.add('border-red-500');
                }
                showError(error);
                return false;
            }
        }

        hideMessages();
        return true;
    }

    // Submit form via AJAX
    async function submitForm(formData) {
        try {
            setButtonState(true);
            hideMessages();

            const response = await fetch('/auth/login', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(formData)
            });

            const result = await response.json();

            if (response.ok) {
                showSuccess('Login successful! Redirecting...');
                
                // Store token if provided
                if (result.token) {
                    AuthUtils.setAuthToken(result.token);
                }
                
                // Redirect to dashboard or home page after 1 second
                setTimeout(() => {
                    window.location.href = '/';
                }, 1000);
            } else {
                let errorMessage = 'Login failed';
                
                if (result.message) {
                    errorMessage = result.message;
                } else if (response.status === 401) {
                    errorMessage = 'Invalid username or password';
                } else if (response.status === 400) {
                    errorMessage = 'Invalid input data';
                }
                
                showError(errorMessage);
            }
        } catch (error) {
            console.error('Login error:', error);
            showError('Network error. Please try again.');
        } finally {
            setButtonState(false);
        }
    }

    // Form submission handler
    loginForm.addEventListener('submit', function(e) {
        e.preventDefault();
        
        if (!validateForm()) {
            return;
        }

        const formData = new FormData(loginForm);
        const data = Object.fromEntries(formData);
        
        submitForm(data);
    });

    // Initialize real-time validation
    setupRealTimeValidation();

    // Check if user is already logged in
    if (AuthUtils.isAuthenticated()) {
        // Redirect to dashboard if already logged in
        window.location.href = '/';
    }
});
