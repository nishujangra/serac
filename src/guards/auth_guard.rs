
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

    async fn from_request(
        request: &'r Request<'_>,
    ) -> Outcome<Self, Self::Error> {
        // extract header
        let auth_header = match request.headers().get_one("Authorization") {
            Some(header) if !header.trim().is_empty() => header,
            _ => return Outcome::Error((Status::Unauthorized, ()))
        };

        // extract token, header must start with bearer
        let token = auth_header.strip_prefix("Bearer ").unwrap().trim();

        // get jwt secret
        let jwt_secret = std::env::var("JWT_SECRET").expect("JWT_SECRET must be set in .env");

        // decode jwt
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