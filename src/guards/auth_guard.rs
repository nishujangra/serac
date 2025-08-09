
use rocket::http::Status;
use rocket::request::{FromRequest, Outcome};
use rocket::Request;
use rocket::serde::{Serialize, Deserialize};
use rocket::async_trait;
use jsonwebtoken::{decode, DecodingKey, Validation, Algorithm};

// Data stored in the JWT
#[derive(Debug, Serialize, Deserialize)]
pub struct Claims {
    pub user_id: String,
    pub role: String,
    pub exp: usize, // expiration timestamp of JWT token
}

// Guard struct
pub struct AuthenticatedUser(pub Claims);

#[async_trait]
impl<'r> FromRequest<'r> for AuthenticatedUser {
    type Error = ();

    async fn from_request(req: &'r Request<'_>) -> Outcome<Self, Self::Error> {
        let auth_header = req.headers().get_one("Authorization");

        if auth_header.is_none() {
            return Outcome::Error((Status::Unauthorized, ()));
        }

        let token = auth_header.unwrap().trim_start_matches("Bearer ").trim();
        let secret = std::env::var("JWT_SECRET").unwrap_or_else(|_| "iwt-secret".to_string());

        match decode::<Claims>(
            token,
            &DecodingKey::from_secret(secret.as_ref()),
            &Validation::new(Algorithm::HS256),
        ) {
            Ok(token_data) => Outcome::Success(AuthenticatedUser(token_data.claims)),
            Err(_) => Outcome::Error((Status::Unauthorized, ())),
        }
    }
}

// Optional role check helper
impl AuthenticatedUser {
    pub fn has_role(&self, role: &str) -> bool {
        self.0.role == role
    }
}