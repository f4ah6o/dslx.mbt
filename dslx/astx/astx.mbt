///|
pub(all) struct Astx {
  name : String
} derive(Debug, Eq)

///|
pub fn astx(name : String) -> Astx {
  { name, }
}
