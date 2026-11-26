async fn do_async() {}
fn f() {
    Some(do_async()).map(|().unwrap_or_default()| {});
}
fn main() {}
