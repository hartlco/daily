

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
use std::fs;
use std::fs::OpenOptions;
use base64::{decode};
use std::time::{SystemTime, UNIX_EPOCH};

#[get("/")]
fn index() -> &'static str {
    "Hello, world!"
}

#[post("/", format = "application/json", data = "<input>")]
fn add_entry(input: Json<Entry>) -> String {
    save_entry(&input.0);
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
    location: String,
    base_64_image: String
}

fn now_date_string() -> String {
    let now: DateTime<Utc> = Utc::now();
    return now.to_rfc3339().to_string();
}

fn save_entry(entry: &Entry) {
    let date = match DateTime::parse_from_rfc3339(&entry.creation_date_string) {
        Err(why) => panic!("couldn't parse date: {}",
                           why.description()),
        Ok(date) => date
    };

    let folder_name = format!("{}", date.format("out/%Y"));
    create_folder_if_needed(&folder_name);
    let file_name = format!("{}/{}.md", folder_name, date.format("%m"));
    let header_date = date.format("%Y-%m-%d");
    let path = Path::new(&file_name);

    let display = path.display();

    let mut content = format!("{}", &entry.content);

    let file_exists = path.exists();

    if entry.base_64_image != "" {
        let assets_name = "assets";
        let asset_folder_name = format!("{}/{}", date.format("out/%Y/"), assets_name);
        create_folder_if_needed(&asset_folder_name);
        let decoded_image = decode(&entry.base_64_image).expect("base64 error");
        let start = SystemTime::now();
        let since_the_epoch = start.duration_since(UNIX_EPOCH)
            .expect("Time went backwards");
        let image_name = format!("{}-{}.jpg", date.format("%Y-%m-%d"), since_the_epoch.as_secs());
        let image_file_name = format!("{}/{}", asset_folder_name, image_name);
        let image_path = Path::new(&image_file_name);

        let mut file = match File::create(&image_path) {
            Err(why) => panic!("couldn't create {}: {}",
                            display,
                            why.description()),
            Ok(file) => file,
        };

        match file.write(&decoded_image) {
            Err(why) => {
                panic!("couldn't write to {}: {}", display,
                                                why.description())
            },
            Ok(_) => println!("successfully wrote to {}", display),
        }

        content = content + "\n\n" + "/" + assets_name + "/" + &image_name + "\n";
    }

    if file_exists {
        let mut file = OpenOptions::new()
        .write(true)
        .append(true)
        .open(path)
        .unwrap();

        if let Err(e) = writeln!(file, "\n\n# {} Ort: {}\n{}", header_date, entry.location, content) {
            eprintln!("Couldn't write to file: {}", e);
        }
    } else {
        content = format!("# {} Ort: {}\n{}", header_date, entry.location, content);

        let mut file = match File::create(&path) {
            Err(why) => panic!("couldn't create {}: {}",
                            display,
                            why.description()),
            Ok(file) => file,
        };

        match file.write_all(content.as_bytes()) {
            Err(why) => {
                panic!("couldn't write to {}: {}", display,
                                                why.description())
            },
            Ok(_) => println!("successfully wrote to {}", display),
        }
    }
}

fn create_folder_if_needed(name: &String) {
    fs::create_dir_all(name);
}