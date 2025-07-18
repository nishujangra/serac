pub mod user_routes;
pub mod auth_routes;

use rocket::Route;

pub fn auth_routes() -> Vec<Route> {
    routes![
        auth_routes::login
    ]
}

pub fn user_routes() -> Vec<Route> {
    routes![
        user_routes::get_user
    ]
}