
use rocket::serde::json::Json;
use crate::models::user::UserLogin;

use rocket_dyn_templates::{Template, context};

#[get("/login")]
pub fn login_page() -> Template {
    Template::render("auth/login", context!{})
}

#[post("/login", format= "json", data = "<user>")]
pub fn login(user: Json<UserLogin>, db: &State<PgPool>) -> Result<Redirect, Status> {
    format!("print test user {:?}", user.0)
}

// #[get("/register")]
// pub fn register_page()


// #[post("/register")]
// pub fn register()