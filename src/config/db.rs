use serde::Deserialize;
use std::fs;
use sqlx::PgPool;

use rocket::serde::json::serde_json;

#[derive(Debug, Deserialize)]
pub struct PgDatabase {
    pub host: String,
    pub port: String,
    pub user: String,
    pub db: String,
}

#[derive(Debug, Deserialize)]
pub struct Config {
    pub pg_database: PgDatabase,
}

impl Config {
    pub fn from_file(path: &str) -> Self {
        let data = fs::read_to_string(path).expect("config.json not found");
        serde_json::from_str(&data).expect("Invalid JSON in config.json")
    }

    pub fn to_database_url(&self) -> String {
        let password = std::env::var("PG_PASSWORD").expect("PG_PASSWORD must be set in .env");

        format!(
            "postgres://{}:{}@{}:{}/{}",
            self.pg_database.user,
            password,
            self.pg_database.host,
            self.pg_database.port,
            self.pg_database.db
        )
    }
}

pub async fn init_db(config: &Config) -> PgPool {
    let db_url = config.to_database_url();

    PgPool::connect(&db_url)
        .await
        .expect("Failed to connect to DB")
}