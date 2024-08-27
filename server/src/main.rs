#![forbid(unsafe_code)]

use axum::routing;
use chrono::Datelike;
use serde::{Deserialize, Serialize};
use std::sync::Arc;

/// Top level JSON data object with offset and daily entries
///
/// `offset` is the offset of days since CE to start with.
/// `daily` is the array of entries with form [Daily].
#[derive(Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
struct Data {
    offset: usize,
    daily: Vec<Daily>,
}

/// Daily entry with some specific content
///
/// `type` is the [Type] of the daily entry.
/// `keywords` describe the daily entry category.
/// `content` is the [Content] with type [Type].
/// `source` is the source of the entry.
#[derive(Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
struct Daily {
    r#type: Type,
    keywords: Vec<String>,
    content: Vec<Content>,
    source: String,
}

/// Type of daily entry with `quote` or `quiz`
#[derive(Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields, rename_all = "lowercase")]
enum Type {
    Quote,
    Quiz,
}

/// Content enum with `quote` as [Quote] or `quiz` as [Quiz]
#[derive(Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields, untagged)]
enum Content {
    Quote(Quote),
    Quiz(Quiz),
}

/// Quote that contains localized text `text` for lang `lang`
#[derive(Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
struct Quote {
    lang: String,
    text: String,
}

/// Quiz that contains localized text `text` for lang `lang`
/// with answer `answer` and decoys `wrong`
#[derive(Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
struct Quiz {
    lang: String,
    text: String,
    answer: String,
    wrong: Vec<String>,
}

/// Start main application using Axum
#[tokio::main]
async fn main() {
    // Reading and parsing JSON
    let json = std::fs::File::open("data.json").expect("File `data.json` could not be opened");
    let data =
        Arc::new(serde_json::from_reader(json).expect("File `data.json` could not be parsed"));
    println!("Successfully loaded `data.json`...");

    // Initialize app with all routes
    // `/api/daily` returns current daily entry
    let app = axum::Router::new().route(
        "/api/daily",
        routing::get({
            let data = Arc::clone(&data);

            move || async move {
                serde_json::to_string(get_daily(&data))
                    .expect("Parsing of current date entry failed")
            }
        }),
    );

    // Open PORT and start application
    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    println!("Serving server on 0.0.0.0:3000...");
    axum::serve(listener, app).await.unwrap()
}

/// Get daily entry of quotes and quizzes
///
/// # Examples
///
/// ```
/// let mut data = Data {
///     offset: chrono::Local::now().num_days_from_ce() as usize,  
///     daily: vec![
///         Daily { r#type: Type::Quote, keywords: vec![], content: vec![], source: String::from("foo") },
///         Daily { r#type: Type::Quote, keywords: vec![], content: vec![], source: String::from("bar") }
///     ]
/// };
///
/// let first_day = get_daily(&data);
/// assert_eq!(first_day.source, "foo");
///
/// // One day passes...
/// data.offset -= 1;
///
/// let second_day = get_daily(&data);
/// assert_eq!(second_day.source, "bar");
/// ```
fn get_daily<'a>(data: &'a Data) -> &'a Daily {
    // Get daily entry using:
    // cycle  - wrap around entries if not enough
    // skip   - get current day since CE with respect to offset
    // next   - stage unwrap without stepping
    // expect - unwrap with panic! if no entries present
    data.daily
        .iter()
        .cycle()
        .skip(chrono::Local::now().num_days_from_ce() as usize - data.offset)
        .next()
        .expect("No entries found")
}
