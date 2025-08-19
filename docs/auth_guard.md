# Authentication Guard Middleware Documentation

## Overview

The Authentication Guard is a custom Rocket request guard that provides JWT-based authentication for protected routes. It validates JWT tokens from the Authorization header and extracts user claims for use in route handlers.

## Implementation

### Location
- **File**: `src/guards/auth_guard.rs`
- **Module**: `crate::guards::auth_guard`

### Core Components

#### Claims Structure
```rust
#[derive(Debug, Serialize, Deserialize)]
pub struct Claims {
    pub user_id: String,
    pub role: String,
    pub exp: usize, // expiration timestamp of JWT token
}
```

#### AuthenticatedUser Guard
```rust
pub struct AuthenticatedUser(pub Claims);
```

## How It Works

### 1. Request Processing Flow

The authentication guard follows this process:

1. **Header Extraction**: Reads the `Authorization` header from the incoming request
2. **Format Validation**: Ensures the header follows `Bearer <token>` format
3. **Token Extraction**: Extracts the JWT token from the header
4. **Environment Check**: Retrieves the JWT secret from environment variables
5. **Token Verification**: Decodes and validates the JWT token
6. **Claims Extraction**: Parses user claims from the validated token
7. **Guard Return**: Returns the authenticated user data or an error

### 2. Implementation Details

```rust
#[async_trait]
impl<'r> FromRequest<'r> for AuthenticatedUser {
    type Error = ();

    async fn from_request(request: &'r Request<'_>) -> Outcome<Self, Self::Error> {
        // Extract and validate Authorization header
        let auth_header = match request.headers().get_one("Authorization") {
            Some(header) if !header.trim().is_empty() => header,
            _ => return Outcome::Error((Status::Unauthorized, ()))
        };

        // Parse Bearer token format
        let token = match auth_header.strip_prefix("Bearer ") {
            Some(t) if !t.trim().is_empty() => t.trim(),
            _ => return Outcome::Error((Status::Unauthorized, ())),
        };

        // Get JWT secret from environment
        let jwt_secret = std::env::var("JWT_SECRET").expect("JWT_SECRET must be set in .env");

        // Decode and validate JWT token
        let result = decode::<Claims>(
            token,
            &DecodingKey::from_secret(jwt_secret.as_bytes()),
            &Validation::new(Algorithm::HS256)
        );

        let claims = match result {
            Ok(data) => data.claims,
            Err(_) => return Outcome::Error((Status::Unauthorized, ())),
        };

        Outcome::Success(AuthenticatedUser(claims))
    }
}
```

## Usage in Routes

### Basic Usage
```rust
use crate::guards::auth_guard::AuthenticatedUser;

#[get("/protected")]
pub fn protected_route(user: AuthenticatedUser) -> Json<Value> {
    Json(json!({
        "message": "Access granted",
        "user_id": user.0.user_id,
        "role": user.0.role
    }))
}
```

### Error Handling
```rust
#[get("/protected")]
pub fn protected_route(user: AuthenticatedUser) -> Result<Json<Value>, Status> {
    // The guard automatically returns 401 Unauthorized if authentication fails
    Ok(Json(json!({
        "message": "Access granted",
        "user_id": user.0.user_id
    })))
}
```

## Security Features

### JWT Token Validation
- **Algorithm**: HS256 (HMAC with SHA-256)
- **Secret Key**: Stored in environment variables
- **Expiration**: Automatic expiration checking via `exp` claim
- **Signature Verification**: Ensures token integrity

### Header Validation
- **Format**: Strict `Bearer <token>` format validation
- **Empty Check**: Rejects empty or whitespace-only headers
- **Token Extraction**: Proper token extraction from header

### Error Handling
- **Unauthorized (401)**: Returned for all authentication failures
- **Graceful Degradation**: Proper error responses without exposing internals
- **Consistent Behavior**: Same error response for all authentication issues

## Configuration

### Environment Variables

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `JWT_SECRET` | ✅ | Secret key for JWT signing/verification | `your-super-secret-key-here` |

### JWT Token Requirements

The guard expects JWT tokens with the following structure:

```json
{
    "user_id": "uuid-string",
    "role": "user-role-string",
    "exp": 1234567890,
    "iat": 1234567890
}
```

## Error Scenarios

### 1. Missing Authorization Header
```http
GET /protected HTTP/1.1
Host: localhost:8000
```
**Response**: `401 Unauthorized`

### 2. Invalid Header Format
```http
GET /protected HTTP/1.1
Host: localhost:8000
Authorization: InvalidFormat token123
```
**Response**: `401 Unauthorized`

### 3. Empty Token
```http
GET /protected HTTP/1.1
Host: localhost:8000
Authorization: Bearer
```
**Response**: `401 Unauthorized`

### 4. Invalid JWT Token
```http
GET /protected HTTP/1.1
Host: localhost:8000
Authorization: Bearer invalid.jwt.token
```
**Response**: `401 Unauthorized`

### 5. Expired Token
```http
GET /protected HTTP/1.1
Host: localhost:8000
Authorization: Bearer expired.jwt.token
```
**Response**: `401 Unauthorized`

### 6. Missing JWT Secret
If `JWT_SECRET` environment variable is not set:
**Response**: Application panic with error message

## Best Practices

### 1. Environment Security
- Store JWT secret in environment variables, never in code
- Use strong, randomly generated secrets
- Rotate secrets periodically in production

### 2. Token Management
- Implement proper token expiration
- Use short-lived tokens for security
- Implement token refresh mechanisms

### 3. Error Handling
- Don't expose internal error details
- Log authentication failures for monitoring
- Implement rate limiting for failed attempts

### 4. Route Protection
- Apply the guard to all sensitive routes
- Consider role-based access control using the role claim
- Implement proper logout mechanisms

## Integration Examples

### Role-Based Access Control
```rust
#[get("/admin")]
pub fn admin_route(user: AuthenticatedUser) -> Result<Json<Value>, Status> {
    if user.0.role != "ADMIN" {
        return Err(Status::Forbidden);
    }
    
    Ok(Json(json!({
        "message": "Admin access granted",
        "user_id": user.0.user_id
    })))
}
```

### Multiple Guards
```rust
#[get("/user/profile")]
pub fn user_profile(
    user: AuthenticatedUser,
    db: &State<PgPool>
) -> Result<Json<Value>, Status> {
    // Access both authenticated user and database
    Ok(Json(json!({
        "user_id": user.0.user_id,
        "role": user.0.role
    })))
}
```

## Testing

### Unit Testing
```rust
#[cfg(test)]
mod tests {
    use super::*;
    use rocket::http::Header;
    use rocket::local::blocking::Client;

    #[test]
    fn test_protected_route_with_valid_token() {
        let client = Client::tracked(rocket()).unwrap();
        let response = client
            .get("/protected")
            .header(Header::new("Authorization", "Bearer valid.token.here"))
            .dispatch();
        
        assert_eq!(response.status(), Status::Ok);
    }

    #[test]
    fn test_protected_route_without_token() {
        let client = Client::tracked(rocket()).unwrap();
        let response = client.get("/protected").dispatch();
        
        assert_eq!(response.status(), Status::Unauthorized);
    }
}
```

## Dependencies

The authentication guard requires the following dependencies:

```toml
[dependencies]
jsonwebtoken = "8.1"
rocket = "0.5"
rocket::serde = { version = "0.5", features = ["json"] }
```

## Future Enhancements

1. **Token Refresh**: Implement automatic token refresh mechanisms
2. **Multiple Algorithms**: Support for different JWT algorithms
3. **Custom Claims**: Extensible claims structure
4. **Rate Limiting**: Built-in rate limiting for failed attempts
5. **Audit Logging**: Authentication attempt logging
6. **Blacklist Support**: Token blacklisting for logout 