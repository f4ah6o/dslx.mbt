///|
pub(all) struct Prnt {
  text : String
} derive(Debug, Eq)

///|
pub fn prnt(text : String) -> Prnt {
  { text, }
}
