use rocket::http::{Status, ContentType};

mod routes;
mod models;

use crate::routes::user_routes::{get_user};
use crate::routes::auth_routes::{login};


#[macro_use] extern crate rocket;

#[get("/")]
fn index() -> (Status, (ContentType, &'static str)) {
    (Status::ImATeapot, (ContentType::JSON, "{ 
        \"status\": \"200\",
        \"msg\": \"SERAC backend initialized]\" 
    }"))
}

#[launch]
fn rocket() -> _ {
    rocket::build()
        .mount("/", routes![index])
        .mount("/auth", routes::auth_routes())
        .mount("/", routes::user_routes())
}