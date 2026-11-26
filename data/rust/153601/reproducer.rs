#![allow(non_camel_case_types)]
#![feature(rustc_attrs)]

enum crew_of_enterprise_d {
    #[rustc_dummy] worf,
}

fn boldly_go(_crew_member: crew_of_enterprise_d, _where: String) {}

fn main_d1342639() {
    boldly_go(crew_of_enterprise_d::worf, "x".to_string());
}

fn foo(x: &isize) {
    let a = 1;
    let mut z = x;
    z = &a;
}

fn main_c31c2192() {
    foo(&1);
}

fn main() {
    main_d1342639();
    main_c31c2192();
}
