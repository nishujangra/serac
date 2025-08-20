use rocket::fairing::{
    Fairing,
    Info,
    Kind
};

use rocket::{
    Request, 
    Data
};
use rocket::async_trait;


pub struct Logger;

#[async_trait]
impl Fairing for Logger {
    fn info(&self) -> Info {
        Info {
            name: "Request Logger",
            kind: Kind::Request | Kind::Response
        }
    }

    async fn on_request(&self, request: &mut Request<'_>, _: &mut Data<'_>) {
        println!("------> Incoming request: {} {}", request.method(), request.uri());
    }

    async fn on_response<'r>(&self, req: &'r Request<'_>, res: &mut rocket::Response<'r>) {
       println!("------> {} {} -> {}", req.method(), req.uri(), res.status());
    }
}