
use crate::models::user::UserLogin;
use rocket::serde::json::Json;

#[get("/user")]
pub fn get_user() -> Json<UserLogin> {
    let user = UserLogin {
        username: "nishujangra27".to_string(),
        email: "nishujangra@zohomail.in".to_string(),
        password: "password".to_string(),
    };

    Json(user)
}