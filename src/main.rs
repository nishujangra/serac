#[macro_use] extern crate rocket;

use rocket::fs::FileServer;
use rocket_dyn_templates::{Template, context};


pub mod routes;
pub mod models;

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
        .mount("/static", FileServer::from("static"))
        .mount("/", routes![index])
        .mount("/auth", routes::auth_routes())
        .mount("/", routes::user_routes())
}