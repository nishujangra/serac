
use rocket::serde::json::Json;
use crate::models::user::UserLogin;

#[get("/login")]
pub fn login_page() -> String {
    format!("This is the login page")
}

#[post("/login", format= "json", data = "<user>")]
pub fn login(user: Json<UserLogin>) -> String {
    format!("print test user {:?}", user.0)
}


// #[get("/register")]
// pub fn register_page()


// #[post("/register")]
// pub fn register()