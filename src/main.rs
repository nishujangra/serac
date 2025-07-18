#[macro_use] extern crate rocket;

use rocket::http::{Status, ContentType};
use rocket_dyn_templates::{Template, context};


mod routes;
mod models;

use crate::routes::user_routes::{get_user};
use crate::routes::auth_routes::{login};

#[get("/")]
fn index() -> Template {
    Template::render("index", context!{
        username: "Nishujangra 27"
    })
}

#[launch]
fn rocket() -> _ {
    rocket::build()
        .attach(Template::fairing())
        .mount("/", routes![index])
        .mount("/auth", routes::auth_routes())
        .mount("/", routes::user_routes())
}