struct Range;

trait Case1<T>
where
    T: Iterator<Item: 'static>,
{
}

struct DataCase1;
impl Case1<Range<u8>> for DataCase1 {}

fn main() {}
