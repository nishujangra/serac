# User Routes API Documentation

## Overview

The User Routes API provides endpoints for accessing user information and managing user data. All endpoints require authentication using JWT tokens through the authentication guard middleware.

## Base URL

All user endpoints are prefixed with `/user`

## Authentication

All user routes require authentication. Include the JWT token in the Authorization header:

```
Authorization: Bearer <your_jwt_token>
```

## Endpoints

### Get Current User Details

**GET** `/user/me`

Retrieve details of the currently authenticated user.

#### Headers

| Header | Type | Required | Description |
|--------|------|----------|-------------|
| `Authorization` | string | ✅ | Bearer token format: `Bearer <jwt_token>` |

#### Response

**Success (200 OK)**
```json
{
    "success": true,
    "user_id": "uuid",
    "role": "string"
}
```

**Error (401 Unauthorized)**
- Missing or invalid Authorization header
- Expired or invalid JWT token
- Malformed token format

#### Example Usage

```bash
curl -X GET http://localhost:8000/user/me \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

## Error Codes

| Code | Description |
|------|-------------|
| 401 | Unauthorized - Invalid or missing authentication token |

## Implementation Details

### Authentication Guard

The user routes use a custom authentication guard (`AuthenticatedUser`) that:

1. **Extracts Authorization Header**: Reads the `Authorization` header from the request
2. **Validates Token Format**: Ensures the header follows `Bearer <token>` format
3. **Verifies JWT Token**: Decodes and validates the JWT token using the secret key
4. **Extracts Claims**: Parses user information from the token payload
5. **Returns User Data**: Provides authenticated user information to the route handler

### JWT Token Structure

The JWT token contains the following claims:

```json
{
    "user_id": "uuid",
    "role": "string",
    "exp": "timestamp"
}
```

### Authentication Guard Implementation

```rust
pub struct AuthenticatedUser(pub Claims);

#[derive(Debug, Serialize, Deserialize)]
pub struct Claims {
    pub user_id: String,
    pub role: String,
    pub exp: usize, // expiration timestamp
}
```

## Security Features

- **JWT Token Validation**: Secure token verification using HS256 algorithm
- **Authorization Header**: Standard Bearer token authentication
- **Token Expiration**: Automatic expiration checking
- **Role-Based Access**: User role information available in routes
- **Secure Secret**: JWT secret stored in environment variables

## Best Practices

1. **Token Security**: Store JWT secret securely in environment variables
2. **Token Expiration**: Implement proper token expiration and refresh mechanisms
3. **Error Handling**: Return appropriate HTTP status codes for authentication failures
4. **Role Validation**: Use role information for additional access control if needed
5. **HTTPS**: Always use HTTPS in production for secure token transmission

## Environment Variables

The authentication guard requires the following environment variable:

| Variable | Description | Example |
|----------|-------------|---------|
| `JWT_SECRET` | Secret key for JWT token signing and verification | `your-secret-key-here` |

## Integration with Other Routes

The authentication guard can be used in any route that requires authentication:

```rust
#[get("/protected-route")]
pub fn protected_route(user: AuthenticatedUser) -> Result<Json<Value>, Status> {
    // Access user information via user.0.user_id, user.0.role, etc.
    Ok(Json(json!({
        "message": "Protected route accessed successfully",
        "user_id": user.0.user_id
    })))
}
```

## Future Enhancements

Potential improvements for the user routes:

1. **User Profile Management**: Add endpoints for updating user profile information
2. **Password Change**: Implement secure password change functionality
3. **User Search**: Add endpoints for searching users (admin only)
4. **Role Management**: Implement role-based access control endpoints
5. **User Deactivation**: Add user account deactivation functionality 