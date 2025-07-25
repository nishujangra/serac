
use rocket::serde::json::Json;
use crate::models::user::{UserLogin, UserRegister};
use rocket::State;

use sqlx::PgPool;

use rocket_dyn_templates::{Template, context};

#[get("/login")]
pub fn login_page() -> Template {
    Template::render("auth/login", context!{})
}

// #[post("/login", format= "json", data = "<user>")]
// pub fn login(user: Json<UserLogin>, db: &State<PgPool>) -> Result<Redirect, Status> {
//     format!("print test user {:?}", user.0)
// }

#[post("/login", format="application/json", data="<user>")]
pub fn login(user: Json<UserLogin>) -> String {
    format!("{} is the email of the logged in user", user.email)
}

#[get("/register")]
pub fn register_page() -> Template {
    Template::render("auth/register", context!{})
}

#[post("/register", format="application/json", data="<user>")]
pub fn register(user: Json<UserRegister>) -> String {
    format!("{} {} is the name of the user\n", user.first_name, user.last_name)
}