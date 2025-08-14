
use crate::models::user::UserLogin;
use crate::guards::auth_guard::AuthenticatedUser;

use rocket::http::{Status};
use rocket::serde::json::{Json, json, Value};

#[get("/me")]
pub fn user_details(user: AuthenticatedUser) -> Result<Json<Value>, Status> {
    Ok(Json(json!({
        "success": true,
        "user_id": user.0.user_id,
        "role": user.0.role.trim() // trim white-spaces
    })))
}