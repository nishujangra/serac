# Authentication API Documentation

## Overview

Serac provides a comprehensive authentication system with role-based access control (RBAC). This document covers the authentication endpoints and their usage.

## Base URL

All authentication endpoints are prefixed with `/auth`

## Endpoints

### Register User

**POST** `/auth/register`

Register a new user account with role-based access control.

#### Request Body

```json
{
    "username": "string",
    "email": "string",
    "password": "string",
    "confirm_password": "string",
    "first_name": "string",
    "last_name": "string",
    "role": "string"
}
```

#### Field Descriptions

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `username` | string | ✅ | Unique username for login (non-empty) |
| `email` | string | ✅ | Valid email address (must contain '@') |
| `password` | string | ✅ | Password (minimum 8 characters) |
| `confirm_password` | string | ✅ | Must match password exactly |
| `first_name` | string | ✅ | User's first name |
| `last_name` | string | ✅ | User's last name |
| `role` | string | ✅ | User role (e.g., ADMIN, DEVELOPER, USER) |

#### Response

**Success (200 OK)**
```json
{
    "message": "User registered successfully",
    "token": "jwt_token",
    "user": {
        "user_id": "uuid",
        "username": "string",
        "email": "string",
        "first_name": "string",
        "last_name": "string",
        "role": "string",
        "created_at": "timestamp",
        "updated_at": "timestamp"
    }
}
```

**Error (400 Bad Request)**
- Invalid email format (missing '@')
- Empty username
- Password less than 8 characters
- Password confirmation mismatch

**Error (409 Conflict)**
- Username already exists

**Error (500 Internal Server Error)**
- Password hashing failure
- JWT token generation failure
- Database insertion failure

#### Example Usage

```bash
curl -X POST http://localhost:8000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "john_doe",
    "email": "john@example.com",
    "password": "securepassword123",
    "confirm_password": "securepassword123",
    "first_name": "John",
    "last_name": "Doe",
    "role": "DEVELOPER"
  }'
```

### Login User

**POST** `/auth/login`

Authenticate user and receive access token.

#### Request Body

```json
{
    "email": "string",
    "password": "string"
}
```

#### Field Descriptions

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `email` | string | ✅ | User's email address |
| `password` | string | ✅ | User password (minimum 8 characters) |

#### Response

**Success (200 OK)**
```json
{
    "email": "string",
    "password": "string",
    "token": "jwt_token"
}
```

**Error (400 Bad Request)**
- Invalid email format (missing '@')
- Password less than 8 characters

**Error (401 Unauthorized)**
- User not found
- Invalid password

**Error (500 Internal Server Error)**
- Password hash parsing failure
- JWT token generation failure

#### Example Usage

```bash
curl -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "securepassword123"
  }'
```

### Register Page

**GET** `/auth/register`

Display the user registration page.

#### Response

**Success (200 OK)**
- Returns HTML template for registration form

#### Example Usage

```bash
curl -X GET http://localhost:8000/auth/register
```

### Login Page

**GET** `/auth/login`

Display the user login page.

#### Response

**Success (200 OK)**
- Returns HTML template for login form

#### Example Usage

```bash
curl -X GET http://localhost:8000/auth/login
```

## Security Features

- **Password Hashing**: All passwords are hashed using Argon2 with random salt generation
- **JWT Tokens**: Secure token-based authentication
- **HttpOnly Cookies**: Tokens are stored in secure, HttpOnly cookies
- **Input Validation**: Comprehensive request validation
- **Email Validation**: Basic email format validation
- **Password Confirmation**: Double password entry for registration
- **Username Uniqueness**: Prevents duplicate usernames

## Validation Rules

### Registration Validation
- **Username**: Must not be empty (trimmed)
- **Email**: Must contain '@' character
- **Password**: Minimum 8 characters
- **Password Confirmation**: Must match password exactly
- **All Fields**: Required for registration
- **Username Uniqueness**: Checked against database

### Login Validation
- **Email**: Must contain '@' character
- **Password**: Minimum 8 characters
- **User Existence**: Verified against database
- **Password Verification**: Argon2 hash verification

## Error Codes

| Code | Description |
|------|-------------|
| 400 | Bad Request - Invalid input data or validation error |
| 401 | Unauthorized - Invalid credentials or user not found |
| 409 | Conflict - Username already exists |
| 500 | Internal Server Error - Server processing error |

## Implementation Details

### Password Hashing
The system uses Argon2 for password hashing:
- **Algorithm**: Argon2id (default)
- **Salt**: Randomly generated using OsRng
- **Security**: Industry-standard password hashing
- **Verification**: Secure password verification on login

### JWT Token Generation
- **Token Type**: JWT (JSON Web Token)
- **Payload**: Contains user_id and role
- **Security**: Signed with secret key
- **Storage**: HttpOnly cookies for security

### Cookie Management
- **Token Storage**: Secure HttpOnly cookies
- **Path**: Set to "/" for application-wide access
- **Security**: HttpOnly flag prevents XSS attacks

### User Model
```rust
struct User {
    user_id: String,        // UUID
    username: String,       // Unique username
    email: String,          // Email address
    password_hash: String,  // Argon2 hash
    first_name: String,     // First name
    last_name: String,      // Last name
    is_active: bool,        // Account status
    role: String,           // User role
    department: Option<String>, // Optional department
    created_at: i32,        // Creation timestamp (epoch)
    updated_at: i32         // Last update timestamp (epoch)
}
```

## Best Practices

1. **Strong Passwords**: Use passwords with at least 8 characters
2. **Secure Storage**: Tokens stored in HttpOnly cookies
3. **Input Validation**: Comprehensive validation on server side
4. **Error Handling**: Proper HTTP status codes for different error types
5. **HTTPS**: Use HTTPS in production for secure communication
6. **Token Management**: Implement proper token refresh and logout mechanisms
7. **Database Security**: Use parameterized queries to prevent SQL injection

## Template Integration

The authentication system integrates with Tera templates:
- **Login Template**: `templates/auth/login.html.tera`
- **Register Template**: `templates/auth/register.html.tera`

Both endpoints support both JSON API and HTML form submissions. 