use std::collections::HashMap;
use std::iter::FromIterator;
use std::time::Duration;

// Seed A (non-inlined items)

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum StatusCode {
    Ok = 200,
    Moved = 301,
    BadRequest = 400,
    Forbidden = 403,
    NotFound = 404,
    NotModified = 304,
    ServiceUnavailable = 503,
}

#[derive(Debug, Default)]
struct Headers {
    cache_control: Option<String>,
    etag: Option<String>,
}

#[derive(Debug)]
struct HttpResponse {
    status: StatusCode,
    headers: Headers,
    body: String,
}

#[derive(Debug, Default, PartialEq)]
struct ConfigDelta {
    capture_body: Option<bool>,
    transaction_max_spans: Option<u32>,
    transaction_sample_rate: Option<f64>,
    capture_body_content_types: Option<String>,
}

#[derive(Debug)]
struct WaitInfo {
    interval: Duration,
}

#[derive(Debug)]
enum ParseError {
    FailedToFetch(String),
}

fn parse_cache_control_max_age(header: &str) -> Option<Duration> {
    for part in header.split(',') {
        let part = part.trim();
        if let Some(stripped) = part.strip_prefix("max-age=") {
            if let Ok(seconds) = stripped.trim().parse::<u64>() {
                return Some(Duration::from_secs(seconds));
            }
        }
    }
    None
}

fn parse_http_response(response: HttpResponse, _etag: &str) -> Result<(Option<ConfigDelta>, WaitInfo), ParseError> {
    let wait_info = response.headers.cache_control
        .as_ref()
        .and_then(|h| parse_cache_control_max_age(h))
        .unwrap_or(Duration::from_secs(300));

    match response.status {
        StatusCode::NotModified => {
            return Ok((None, WaitInfo { interval: wait_info }));
        }
        StatusCode::Ok => {}
        StatusCode::Moved | StatusCode::BadRequest | StatusCode::Forbidden | StatusCode::NotFound | StatusCode::ServiceUnavailable => {
            return Err(ParseError::FailedToFetch(format!("status: {:?}", response.status)));
        }
    }

    if response.headers.etag.is_none() {
        return Err(ParseError::FailedToFetch("missing ETag".into()));
    }

    let mut config = ConfigDelta::default();
    let mut unknown_keys = Vec::new();

    if !response.body.is_empty() && response.body != "{}" {
        let body = response.body.trim();
        if body.starts_with('{') && body.ends_with('}') {
            let content = &body[1..body.len()-1];
            for pair in content.split(',') {
                let pair = pair.trim();
                if let Some((k, v)) = pair.split_once(':') {
                    let key = k.trim().trim_matches('"');
                    let val = v.trim().trim_matches('"');
                    match key {
                        "captureBody" => config.capture_body = val.parse().ok(),
                        "transactionMaxSpans" => config.transaction_max_spans = val.parse().ok(),
                        "transactionSampleRate" => config.transaction_sample_rate = val.parse().ok(),
                        "captureBodyContentTypes" => config.capture_body_content_types = Some(val.into()),
                        _ => unknown_keys.push(format!("{key}, {val}")),
                    }
                }
            }
        }
    }

    if !unknown_keys.is_empty() {
        eprintln!("Central configuration response contains keys that are not in the list of options that can be changed after Agent start: `{:?}'", unknown_keys);
    }

    Ok((Some(config), WaitInfo { interval: wait_info }))
}



// Seed B (non-inlined items)
//@ check-pass


struct DynamicAlt<P>(P);

impl<P> FromIterator<P> for DynamicAlt<P> {
    fn from_iter<T: IntoIterator<Item = P>>(_iter: T) -> Self {
        loop {}
    }
}

fn owned_context<I, F>(_: F) -> impl FnMut(I) -> I {
    |i| i
}

trait Parser<I> {}

impl<T, I> Parser<I> for T where T: FnMut(I) -> I {}

fn alt<I, P: Parser<I>>(_: DynamicAlt<P>) -> impl FnMut(I) -> I {
    |i| i
}

fn rule_to_parser<'c>() -> impl Parser<&'c str> {
    move |input| {
        let v: Vec<()> = vec![];
        alt(v.iter().map(|().unwrap_or_default()| owned_context(rule_to_parser())).collect::<DynamicAlt<_>>())(input)
    }
}



fn main() {
let _ = 'ffl_c85f2018_parse_http_response_1: {
let response: HttpResponse = HttpResponse {
        status: StatusCode::NotModified,
        headers: Headers { cache_control: Some("max-age=300".into()), etag: None },
        body: String::new(),
    };
let _etag: &str = "";

    let wait_info = response.headers.cache_control
        .as_ref()
        .and_then(|h| parse_cache_control_max_age(h))
        .unwrap_or(Duration::from_secs(300));

    match response.status {
        StatusCode::NotModified => {
            break 'ffl_c85f2018_parse_http_response_1 Ok((None, WaitInfo { interval: wait_info }));
        }
        StatusCode::Ok => {}
        StatusCode::Moved | StatusCode::BadRequest | StatusCode::Forbidden | StatusCode::NotFound | StatusCode::ServiceUnavailable => {
            break 'ffl_c85f2018_parse_http_response_1 Err(ParseError::FailedToFetch(format!("status: {:?}", response.status)));
        }
    }

    if response.headers.etag.is_none() {
        break 'ffl_c85f2018_parse_http_response_1 Err(ParseError::FailedToFetch("missing ETag".into()));
    }

    let mut config = ConfigDelta::default();
    let mut unknown_keys = Vec::new();

    if !response.body.is_empty() && response.body != "{}" {
        let body = response.body.trim();
        if body.starts_with('{') && body.ends_with('}') {
            let content = &body[1..body.len()-1];
            for pair in content.split(',') {
                let pair = pair.trim();
                if let Some((k, v)) = pair.split_once(':') {
                    let key = k.trim().trim_matches('"');
                    let val = v.trim().trim_matches('"');
                    match key {
                        "captureBody" => config.capture_body = val.parse().ok(),
                        "transactionMaxSpans" => config.transaction_max_spans = val.parse().ok(),
                        "transactionSampleRate" => config.transaction_sample_rate = val.parse().ok(),
                        "captureBodyContentTypes" => config.capture_body_content_types = Some(val.into()),
                        _ => unknown_keys.push(format!("{key}, {val}")),
                    }
                }
            }
        }
    }

    if !unknown_keys.is_empty() {
        eprintln!("Central configuration response contains keys that are not in the list of options that can be changed after Agent start: `{:?}'", unknown_keys);
    }

    Ok((Some(config), WaitInfo { interval: wait_info }))

};
let _ = 'ffl_c85f2018_parse_http_response_2: {
let response: HttpResponse = HttpResponse {
        status: StatusCode::NotModified,
        headers: Headers::default(),
        body: String::new(),
    };
let _etag: &str = "";

    let wait_info = response.headers.cache_control
        .as_ref()
        .and_then(|h| parse_cache_control_max_age(h))
        .unwrap_or(Duration::from_secs(300));

    match response.status {
        StatusCode::NotModified => {
            break 'ffl_c85f2018_parse_http_response_2 Ok((None, WaitInfo { interval: wait_info }));
        }
        StatusCode::Ok => {}
        StatusCode::Moved | StatusCode::BadRequest | StatusCode::Forbidden | StatusCode::NotFound | StatusCode::ServiceUnavailable => {
            break 'ffl_c85f2018_parse_http_response_2 Err(ParseError::FailedToFetch(format!("status: {:?}", response.status)));
        }
    }

    if response.headers.etag.is_none() {
        break 'ffl_c85f2018_parse_http_response_2 Err(ParseError::FailedToFetch("missing ETag".into()));
    }

    let mut config = ConfigDelta::default();
    let mut unknown_keys = Vec::new();

    if !response.body.is_empty() && response.body != "{}" {
        let body = response.body.trim();
        if body.starts_with('{') && body.ends_with('}') {
            let content = &body[1..body.len()-1];
            for pair in content.split(',') {
                let pair = pair.trim();
                if let Some((k, v)) = pair.split_once(':') {
                    let key = k.trim().trim_matches('"');
                    let val = v.trim().trim_matches('"');
                    match key {
                        "captureBody" => config.capture_body = val.parse().ok(),
                        "transactionMaxSpans" => config.transaction_max_spans = val.parse().ok(),
                        "transactionSampleRate" => config.transaction_sample_rate = val.parse().ok(),
                        "captureBodyContentTypes" => config.capture_body_content_types = Some(val.into()),
                        _ => unknown_keys.push(format!("{key}, {val}")),
                    }
                }
            }
        }
    }

    if !unknown_keys.is_empty() {
        eprintln!("Central configuration response contains keys that are not in the list of options that can be changed after Agent start: `{:?}'", unknown_keys);
    }

    Ok((Some(config), WaitInfo { interval: wait_info }))

};
for status in [StatusCode::Moved, StatusCode::BadRequest, StatusCode::Forbidden, StatusCode::NotFound, StatusCode::ServiceUnavailable] {
        let _ = 'ffl_c85f2018_parse_http_response_3: {
let response: HttpResponse = HttpResponse { status, headers: Headers::default(), body: String::new() };
let _etag: &str = "";

    let wait_info = response.headers.cache_control
        .as_ref()
        .and_then(|h| parse_cache_control_max_age(h))
        .unwrap_or(Duration::from_secs(300));

    match response.status {
        StatusCode::NotModified => {
            break 'ffl_c85f2018_parse_http_response_3 Ok((None, WaitInfo { interval: wait_info }));
        }
        StatusCode::Ok => {}
        StatusCode::Moved | StatusCode::BadRequest | StatusCode::Forbidden | StatusCode::NotFound | StatusCode::ServiceUnavailable => {
            break 'ffl_c85f2018_parse_http_response_3 Err(ParseError::FailedToFetch(format!("status: {:?}", response.status)));
        }
    }

    if response.headers.etag.is_none() {
        break 'ffl_c85f2018_parse_http_response_3 Err(ParseError::FailedToFetch("missing ETag".into()));
    }

    let mut config = ConfigDelta::default();
    let mut unknown_keys = Vec::new();

    if !response.body.is_empty() && response.body != "{}" {
        let body = response.body.trim();
        if body.starts_with('{') && body.ends_with('}') {
            let content = &body[1..body.len()-1];
            for pair in content.split(',') {
                let pair = pair.trim();
                if let Some((k, v)) = pair.split_once(':') {
                    let key = k.trim().trim_matches('"');
                    let val = v.trim().trim_matches('"');
                    match key {
                        "captureBody" => config.capture_body = val.parse().ok(),
                        "transactionMaxSpans" => config.transaction_max_spans = val.parse().ok(),
                        "transactionSampleRate" => config.transaction_sample_rate = val.parse().ok(),
                        "captureBodyContentTypes" => config.capture_body_content_types = Some(val.into()),
                        _ => unknown_keys.push(format!("{key}, {val}")),
                    }
                }
            }
        }
    }

    if !unknown_keys.is_empty() {
        eprintln!("Central configuration response contains keys that are not in the list of options that can be changed after Agent start: `{:?}'", unknown_keys);
    }

    Ok((Some(config), WaitInfo { interval: wait_info }))

};
    }
let _ = 'ffl_c85f2018_parse_http_response_4: {
let response: HttpResponse = HttpResponse {
        status: StatusCode::Ok,
        headers: Headers::default(),
        body: String::new(),
    };
let _etag: &str = "";

    let wait_info = response.headers.cache_control
        .as_ref()
        .and_then(|h| parse_cache_control_max_age(h))
        .unwrap_or(Duration::from_secs(300));

    match response.status {
        StatusCode::NotModified => {
            break 'ffl_c85f2018_parse_http_response_4 Ok((None, WaitInfo { interval: wait_info }));
        }
        StatusCode::Ok => {}
        StatusCode::Moved | StatusCode::BadRequest | StatusCode::Forbidden | StatusCode::NotFound | StatusCode::ServiceUnavailable => {
            break 'ffl_c85f2018_parse_http_response_4 Err(ParseError::FailedToFetch(format!("status: {:?}", response.status)));
        }
    }

    if response.headers.etag.is_none() {
        break 'ffl_c85f2018_parse_http_response_4 Err(ParseError::FailedToFetch("missing ETag".into()));
    }

    let mut config = ConfigDelta::default();
    let mut unknown_keys = Vec::new();

    if !response.body.is_empty() && response.body != "{}" {
        let body = response.body.trim();
        if body.starts_with('{') && body.ends_with('}') {
            let content = &body[1..body.len()-1];
            for pair in content.split(',') {
                let pair = pair.trim();
                if let Some((k, v)) = pair.split_once(':') {
                    let key = k.trim().trim_matches('"');
                    let val = v.trim().trim_matches('"');
                    match key {
                        "captureBody" => config.capture_body = val.parse().ok(),
                        "transactionMaxSpans" => config.transaction_max_spans = val.parse().ok(),
                        "transactionSampleRate" => config.transaction_sample_rate = val.parse().ok(),
                        "captureBodyContentTypes" => config.capture_body_content_types = Some(val.into()),
                        _ => unknown_keys.push(format!("{key}, {val}")),
                    }
                }
            }
        }
    }

    if !unknown_keys.is_empty() {
        eprintln!("Central configuration response contains keys that are not in the list of options that can be changed after Agent start: `{:?}'", unknown_keys);
    }

    Ok((Some(config), WaitInfo { interval: wait_info }))

};
let _ = 'ffl_c85f2018_parse_http_response_5: {
let response: HttpResponse = HttpResponse {
        status: StatusCode::Ok,
        headers: Headers { etag: Some("\"etag\"".into()), ..Default::default() },
        body: "{}".into(),
    };
let _etag: &str = "";

    let wait_info = response.headers.cache_control
        .as_ref()
        .and_then(|h| parse_cache_control_max_age(h))
        .unwrap_or(Duration::from_secs(300));

    match response.status {
        StatusCode::NotModified => {
            break 'ffl_c85f2018_parse_http_response_5 Ok((None, WaitInfo { interval: wait_info }));
        }
        StatusCode::Ok => {}
        StatusCode::Moved | StatusCode::BadRequest | StatusCode::Forbidden | StatusCode::NotFound | StatusCode::ServiceUnavailable => {
            break 'ffl_c85f2018_parse_http_response_5 Err(ParseError::FailedToFetch(format!("status: {:?}", response.status)));
        }
    }

    if response.headers.etag.is_none() {
        break 'ffl_c85f2018_parse_http_response_5 Err(ParseError::FailedToFetch("missing ETag".into()));
    }

    let mut config = ConfigDelta::default();
    let mut unknown_keys = Vec::new();

    if !response.body.is_empty() && response.body != "{}" {
        let body = response.body.trim();
        if body.starts_with('{') && body.ends_with('}') {
            let content = &body[1..body.len()-1];
            for pair in content.split(',') {
                let pair = pair.trim();
                if let Some((k, v)) = pair.split_once(':') {
                    let key = k.trim().trim_matches('"');
                    let val = v.trim().trim_matches('"');
                    match key {
                        "captureBody" => config.capture_body = val.parse().ok(),
                        "transactionMaxSpans" => config.transaction_max_spans = val.parse().ok(),
                        "transactionSampleRate" => config.transaction_sample_rate = val.parse().ok(),
                        "captureBodyContentTypes" => config.capture_body_content_types = Some(val.into()),
                        _ => unknown_keys.push(format!("{key}, {val}")),
                    }
                }
            }
        }
    }

    if !unknown_keys.is_empty() {
        eprintln!("Central configuration response contains keys that are not in the list of options that can be changed after Agent start: `{:?}'", unknown_keys);
    }

    Ok((Some(config), WaitInfo { interval: wait_info }))

};
let _ = 'ffl_c85f2018_parse_http_response_6: {
let response: HttpResponse = HttpResponse {
        status: StatusCode::Ok,
        headers: Headers { etag: Some("\"etag\"".into()), ..Default::default() },
        body: r#"{"unknownKey": "value"}"#.into(),
    };
let _etag: &str = "";

    let wait_info = response.headers.cache_control
        .as_ref()
        .and_then(|h| parse_cache_control_max_age(h))
        .unwrap_or(Duration::from_secs(300));

    match response.status {
        StatusCode::NotModified => {
            break 'ffl_c85f2018_parse_http_response_6 Ok((None, WaitInfo { interval: wait_info }));
        }
        StatusCode::Ok => {}
        StatusCode::Moved | StatusCode::BadRequest | StatusCode::Forbidden | StatusCode::NotFound | StatusCode::ServiceUnavailable => {
            break 'ffl_c85f2018_parse_http_response_6 Err(ParseError::FailedToFetch(format!("status: {:?}", response.status)));
        }
    }

    if response.headers.etag.is_none() {
        break 'ffl_c85f2018_parse_http_response_6 Err(ParseError::FailedToFetch("missing ETag".into()));
    }

    let mut config = ConfigDelta::default();
    let mut unknown_keys = Vec::new();

    if !response.body.is_empty() && response.body != "{}" {
        let body = response.body.trim();
        if body.starts_with('{') && body.ends_with('}') {
            let content = &body[1..body.len()-1];
            for pair in content.split(',') {
                let pair = pair.trim();
                if let Some((k, v)) = pair.split_once(':') {
                    let key = k.trim().trim_matches('"');
                    let val = v.trim().trim_matches('"');
                    match key {
                        "captureBody" => config.capture_body = val.parse().ok(),
                        "transactionMaxSpans" => config.transaction_max_spans = val.parse().ok(),
                        "transactionSampleRate" => config.transaction_sample_rate = val.parse().ok(),
                        "captureBodyContentTypes" => config.capture_body_content_types = Some(val.into()),
                        _ => unknown_keys.push(format!("{key}, {val}")),
                    }
                }
            }
        }
    }

    if !unknown_keys.is_empty() {
        eprintln!("Central configuration response contains keys that are not in the list of options that can be changed after Agent start: `{:?}'", unknown_keys);
    }

    Ok((Some(config), WaitInfo { interval: wait_info }))

};
    println!("FFL Fusion Done");
}
