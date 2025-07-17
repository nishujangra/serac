#[macro_use] extern crate rocket;
use rocket::http::{Status, ContentType};

#[get("/")]
fn index() -> (Status, (ContentType, &'static str)) {
    (Status::ImATeapot, (ContentType::JSON, "{ \"msg\": \"SERAC backend initialized\" }"))
}

#[launch]
fn rocket() -> _ {
    rocket::build().mount("/", routes![index])
}