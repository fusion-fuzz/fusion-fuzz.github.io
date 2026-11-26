//@ run-pass

fn main() {
    match b"." as &[u8] {
        b"." if true => {},
        b"." => panic!(),
        b".." => panic!(),
        b"" => panic!(),
        _ => panic!(),
    }
    match b"." as &[u8] {
        b"." if false => panic!(),
        b"." => {},
        b".." => panic!(),
        b"" => panic!(),
        _ => panic!(),
    }
    match b".." as &[u8] {
        b"." if true => panic!(), // the miscompile caused this arm to be reached
        b"." => panic!(),
        b".." => {},
        b"" => panic!(),
        _ => panic!(),
    }
    match b".." as &[u8] {
        b"." if false => panic!(),
        b"." => panic!(),
        b".." => {},
        b"" => panic!(),
        _ => panic!(),
    }
    match b"" as &[u8] {
        b"." if true => panic!(),
        b"." => panic!(),
        b".." => panic!(),
        b"" => {},
        _ => panic!(),
    }
    match b"" as &[u8] {
        b"." if false => panic!(),
        b"." => panic!(),
        b".." => panic!(),
        b"" => {},
        _ => panic!(),
    }
}
//@ run-pass

struct Struct<S, T> {
    a: S,
    b: T,
}




fn main_ee4befc9() {

struct TupleStruct<S, T>(S, T);

    let (a, b, c, d);
    Struct { a: TupleStruct((a, b), c), b: [d] } =
        Struct { a: TupleStruct((0, 1), 2), b: [3] };
    assert_eq!((a, b, c, d), (0, 1, 2, 3));

    // unnested underscore: just discard
    _ = 1;

}
