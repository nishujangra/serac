// Register form functionality
document.addEventListener('DOMContentLoaded', function() {
    const registerForm = document.getElementById('registerForm');
    const submitButton = document.querySelector('button[type="submit"]');
    const errorContainer = document.getElementById('errorContainer');
    const successContainer = document.getElementById('successContainer');

    // Form validation functions
    function validateUsername(username) {
        if (!username || username.trim().length < 3) {
            return 'Username must be at least 3 characters long';
        }
        if (!/^[a-zA-Z0-9_]+$/.test(username)) {
            return 'Username can only contain letters, numbers, and underscores';
        }
        return null;
    }

    function validateEmail(email) {
        if (!email || !email.includes('@')) {
            return 'Please enter a valid email address';
        }
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            return 'Please enter a valid email address';
        }
        return null;
    }

    function validatePassword(password) {
        if (!password || password.length < 8) {
            return 'Password must be at least 8 characters long';
        }
        if (!/(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/.test(password)) {
            return 'Password must contain at least one uppercase letter, one lowercase letter, and one number';
        }
        return null;
    }

    function validateConfirmPassword(password, confirmPassword) {
        if (password !== confirmPassword) {
            return 'Passwords do not match';
        }
        return null;
    }

    function validateName(name, fieldName) {
        if (!name || name.trim().length < 2) {
            return `${fieldName} must be at least 2 characters long`;
        }
        if (!/^[a-zA-Z\s]+$/.test(name)) {
            return `${fieldName} can only contain letters and spaces`;
        }
        return null;
    }

    function validateRole(role) {
        if (!role || role === 'Select role') {
            return 'Please select a role';
        }
        const validRoles = ['ADMIN', 'DEVELOPER', 'GUEST'];
        if (!validRoles.includes(role)) {
            return 'Please select a valid role';
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
            registerForm.insertBefore(errorDiv, registerForm.firstChild);
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
            registerForm.insertBefore(successDiv, registerForm.firstChild);
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
                submitButton.textContent = 'Creating Account...';
                submitButton.classList.add('opacity-50', 'cursor-not-allowed');
            } else {
                submitButton.disabled = false;
                submitButton.textContent = 'Create Account';
                submitButton.classList.remove('opacity-50', 'cursor-not-allowed');
            }
        }
    }

    // Real-time validation
    function setupRealTimeValidation() {
        const inputs = registerForm.querySelectorAll('input, select');
        
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
            case 'email':
                error = validateEmail(value);
                break;
            case 'password':
                error = validatePassword(value);
                break;
            case 'confirm_password':
                const password = document.getElementById('password').value;
                error = validateConfirmPassword(password, value);
                break;
            case 'first_name':
                error = validateName(value, 'First name');
                break;
            case 'last_name':
                error = validateName(value, 'Last name');
                break;
            case 'role':
                error = validateRole(value);
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
        const formData = new FormData(registerForm);
        const data = Object.fromEntries(formData);
        
        const validations = [
            { field: 'username', value: data.username, validator: validateUsername },
            { field: 'email', value: data.email, validator: validateEmail },
            { field: 'password', value: data.password, validator: validatePassword },
            { field: 'confirm_password', value: data.confirm_password, validator: (val) => validateConfirmPassword(data.password, val) },
            { field: 'first_name', value: data.first_name, validator: (val) => validateName(val, 'First name') },
            { field: 'last_name', value: data.last_name, validator: (val) => validateName(val, 'Last name') },
            { field: 'role', value: data.role, validator: validateRole }
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

            const response = await fetch('/auth/register', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(formData)
            });

            const result = await response.json();

            if (response.ok) {
                showSuccess('Account created successfully! Redirecting to login...');
                
                // Store token if provided
                if (result.token) {
                    AuthUtils.setAuthToken(result.token);
                }
                
                // Redirect to login page after 2 seconds
                setTimeout(() => {
                    window.location.href = '/auth/login';
                }, 2000);
            } else {
                let errorMessage = 'Registration failed';
                
                if (result.message) {
                    errorMessage = result.message;
                } else if (response.status === 409) {
                    errorMessage = 'Username already exists';
                } else if (response.status === 400) {
                    errorMessage = 'Invalid input data';
                }
                
                showError(errorMessage);
            }
        } catch (error) {
            console.error('Registration error:', error);
            showError('Network error. Please try again.');
        } finally {
            setButtonState(false);
        }
    }

    // Form submission handler
    registerForm.addEventListener('submit', function(e) {
        e.preventDefault();
        
        if (!validateForm()) {
            return;
        }

        const formData = new FormData(registerForm);
        const data = Object.fromEntries(formData);
        
        submitForm(data);
    });

    // Initialize real-time validation
    setupRealTimeValidation();

    // Password strength indicator
    const passwordInput = document.getElementById('password');
    if (passwordInput) {
        passwordInput.addEventListener('input', function() {
            const password = this.value;
            const strengthIndicator = document.getElementById('passwordStrength');
            
            if (!strengthIndicator) {
                const indicator = document.createElement('div');
                indicator.id = 'passwordStrength';
                indicator.className = 'mt-1 text-xs';
                this.parentNode.appendChild(indicator);
            }
            
            let strength = 0;
            let message = '';
            let color = '';
            
            if (password.length >= 8) strength++;
            if (/[a-z]/.test(password)) strength++;
            if (/[A-Z]/.test(password)) strength++;
            if (/\d/.test(password)) strength++;
            if (/[^A-Za-z0-9]/.test(password)) strength++;
            
            switch (strength) {
                case 0:
                case 1:
                    message = 'Very Weak';
                    color = 'text-red-500';
                    break;
                case 2:
                    message = 'Weak';
                    color = 'text-orange-500';
                    break;
                case 3:
                    message = 'Fair';
                    color = 'text-yellow-500';
                    break;
                case 4:
                    message = 'Good';
                    color = 'text-blue-500';
                    break;
                case 5:
                    message = 'Strong';
                    color = 'text-green-500';
                    break;
            }
            
            strengthIndicator.textContent = `Password strength: ${message}`;
            strengthIndicator.className = `mt-1 text-xs ${color}`;
        });
    }
});
