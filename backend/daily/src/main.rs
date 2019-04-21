

#![feature(proc_macro_hygiene, decl_macro)]

#[macro_use] extern crate rocket;
extern crate rocket_contrib;
extern crate chrono;

use rocket_contrib::json::Json;
use serde::{Serialize, Deserialize};
use chrono::{DateTime, Utc};
use std::error::Error;
use std::io::prelude::*;
use std::fs::File;
use std::path::Path;

#[get("/")]
fn index() -> &'static str {
    "Hello, world!"
}

#[post("/", format = "application/json", data = "<input>")]
fn add_entry(input: Json<Entry>) -> String {
    save_entry(input.0);
    return String::from("All good");
}

fn main() {
    // rocket::ignite().mount("/", routes![index]).launch();
    rocket::ignite().mount("/", routes![add_entry]).launch();
}

#[derive(Serialize, Deserialize, Debug)]
struct Entry {
    #[serde(default = "now_date_string")]
    creation_date_string: String,
    content: String,
    location: String
}

fn now_date_string() -> String {
    let now: DateTime<Utc> = Utc::now();
    return now.to_rfc3339().to_string();
}

fn save_entry(entry: Entry) {
    let mut date = match DateTime::parse_from_rfc3339(&entry.creation_date_string) {
        Err(why) => panic!("couldn't parse date: {}",
                           why.description()),
        Ok(date) => date
    };

    let file_name = format!("out/{}.md", entry.creation_date_string);
    let header_date = date.format("%Y-%m-%d");
    println!("{}", file_name);
    let path = Path::new(&file_name);

    let display = path.display();

    let mut content = String::from(entry.content);
    content = format!("# {} Ort: {}\n{}", header_date, entry.location, content);

    // Open a file in write-only mode, returns `io::Result<File>`
    let mut file = match File::create(&path) {
        Err(why) => panic!("couldn't create {}: {}",
                           display,
                           why.description()),
        Ok(file) => file,
    };

    // Write the `LOREM_IPSUM` string to `file`, returns `io::Result<()>`
    match file.write_all(content.as_bytes()) {
        Err(why) => {
            panic!("couldn't write to {}: {}", display,
                                               why.description())
        },
        Ok(_) => println!("successfully wrote to {}", display),
    }
}