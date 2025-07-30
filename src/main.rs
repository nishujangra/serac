#[macro_use] extern crate rocket;

use rocket::fs::FileServer;
use rocket_dyn_templates::{Template, context};


pub mod routes;
pub mod models;
pub mod config;
pub mod utils;

use config::db::Config;
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

    let app_config = Config::from_file("config.json");
    let db_pool = init_db(&app_config).await;

    rocket::build()
        .manage(db_pool)
        .attach(Template::fairing())
        .mount("/static", FileServer::from("static"))
        .mount("/", routes![index])
        .mount("/auth", routes::auth_routes())
        .mount("/", routes::user_routes())
        .launch()
        .await?;

    Ok(())
}