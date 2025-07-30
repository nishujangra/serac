use chrono::{Utc, Duration};
use serde::{Serialize, Deserialize};
use std;

use jsonwebtoken::{encode, EncodingKey, Header};


#[derive(Debug, Serialize, Deserialize)]
pub struct Claims {
    pub id: String,         // user ID or username
    pub exp: usize,          // expiry time (as timestamp)
    pub role: String,        // optional: include user role
}

pub fn generate_token(user_id: String, role: String) -> Result<String, jsonwebtoken::errors::Error> {
    let JWT_SECRET = std::env::var("JWT_SECRET").expect("JWT_SECRET must be in .env");
    let expiration = Utc::now()
        .checked_add_signed(Duration::hours(24))
        .expect("valid timestamp")
        .timestamp() as usize;

    let claims = Claims {
        id: user_id,
        exp: expiration,
        role,
    };

    encode(&Header::default(), &claims, &EncodingKey::from_secret(JWT_SECRET.as_bytes()))
}