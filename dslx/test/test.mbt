///|
pub(all) struct Tstx {
  name : String
} derive(Debug, Eq)

///|
pub fn tstx(name : String) -> Tstx {
  { name, }
}
