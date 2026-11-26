#![feature(gca_min_const_items, gca_const_items, loop_match)]
#![allow(incomplete_features)]

trait Foo {
    const TARGET: u8;

    fn test_u8(mut state: u8) -> &'static str {
        #[loop_match]
        loop {
            state = 'blk: {
                match state {
                    0 => {
                        #[const_continue]
                        break 'blk Self::TARGET;
                    }
                    _ => return "done",
                }
            }
        }
    }
}
