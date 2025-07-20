pub mod user_routes;
pub mod auth_routes;

use rocket::Route;

pub fn auth_routes() -> Vec<Route> {
    routes![
        auth_routes::login_page,
        auth_routes::login
        // auth_routes::register_page
        // auth_routes::register
    ]
}

pub fn user_routes() -> Vec<Route> {
    routes![
        user_routes::get_user
    ]
}