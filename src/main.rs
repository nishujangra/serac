#[macro_use] extern crate rocket;

use rocket::fs::FileServer;
use rocket_dyn_templates::{Template, context};


pub mod routes;
pub mod models;
pub mod config;
pub mod utils;
pub mod fairings;
pub mod guards;

use config::db::init_db;

#[get("/")]
fn index() -> Template {
    Template::render("index", context!{
        username: "Nishujangra 27"
    })
}

#[get("/ping")]
fn ping() -> &'static str {
    "pong"
}

#[rocket::main]
async fn main() -> Result<(), rocket::Error> {
    dotenvy::dotenv().ok(); // load from .env
    let db_pool = init_db().await;

    rocket::build()
        .manage(db_pool)
        .attach(Template::fairing())
        .attach(fairings::logger::Logger)
        .mount("/static", FileServer::from("static"))
        .mount("/", routes![index, ping])
        .mount("/auth", routes::auth_routes())
        .mount("/user", routes::user_routes())
        .launch()
        .await?;

    Ok(())
}