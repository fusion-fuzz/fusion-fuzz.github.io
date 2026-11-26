#[repr(transparent)]
struct P<T: Tr>(std::ptr::NonNull<T::A>);
trait Tr {
    type A: ?Sized;
}
extern "C" fn f<T: Tr>(_: Option<P<T>>) {}
fn main() {}
