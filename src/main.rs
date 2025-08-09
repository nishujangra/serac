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

#[rocket::main]
async fn main() -> Result<(), rocket::Error> {
    dotenvy::dotenv().ok(); // load from .env
    let db_pool = init_db().await;

    rocket::build()
        .manage(db_pool)
        .attach(Template::fairing())
        .mount("/static", FileServer::from("static"))
        .mount("/", routes![index])
        .mount("/auth", routes::auth_routes())
        .mount("/user", routes::user_routes())
        .launch()
        .await?;

    Ok(())
}