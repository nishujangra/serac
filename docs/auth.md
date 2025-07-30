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
    "success": true,
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
```json
{
    "error": "Invalid input data"
}
```

**Error (500 Internal Server Error)**
```json
{
    "error": "Internal server error"
}
```

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
    "username": "string",
    "password": "string"
}
```

#### Field Descriptions

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `username` | string | ✅ | Username or email address |
| `password` | string | ✅ | User password |

#### Response

**Success (200 OK)**
```json
{
    "username": "string",
    "password": "string"
}
```

**Error (400 Bad Request)**
```json
{
    "error": "Invalid credentials"
}
```

#### Example Usage

```bash
curl -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "john_doe",
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

- **Password Hashing**: All passwords are hashed using Argon2
- **JWT Tokens**: Secure token-based authentication
- **Input Validation**: Comprehensive request validation
- **Email Validation**: Basic email format validation
- **Password Confirmation**: Double password entry for registration

## Validation Rules

### Registration Validation
- **Username**: Must not be empty
- **Email**: Must contain '@' character
- **Password**: Minimum 8 characters
- **Password Confirmation**: Must match password exactly
- **All Fields**: Required for registration

### Login Validation
- **Username**: Required
- **Password**: Required

## Error Codes

| Code | Description |
|------|-------------|
| 400 | Bad Request - Invalid input data or validation error |
| 500 | Internal Server Error - Server processing error |

## Implementation Details

### Password Hashing
The system uses Argon2 for password hashing:
- **Algorithm**: Argon2id (default)
- **Salt**: Randomly generated using OsRng
- **Security**: Industry-standard password hashing

### JWT Token Generation
- **Token Type**: JWT (JSON Web Token)
- **Payload**: Contains user_id and role
- **Security**: Signed with secret key

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
    created_at: DateTime,   // Creation timestamp
    updated_at: DateTime    // Last update timestamp
}
```

## Best Practices

1. **Strong Passwords**: Use passwords with at least 8 characters
2. **Secure Storage**: Store tokens securely (httpOnly cookies recommended)
3. **Input Validation**: Always validate input on both client and server
4. **Error Handling**: Handle authentication errors gracefully
5. **HTTPS**: Use HTTPS in production for secure communication
6. **Token Management**: Implement proper token refresh and logout mechanisms

## Template Integration

The authentication system integrates with Tera templates:
- **Login Template**: `templates/auth/login.html.tera`
- **Register Template**: `templates/auth/register.html.tera`

Both endpoints support both JSON API and HTML form submissions. 