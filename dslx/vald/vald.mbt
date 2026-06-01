///|
pub(all) struct Vald {
  name : String
} derive(Debug, Eq)

///|
pub fn vald(name : String) -> Vald {
  { name, }
}
