///|
pub(all) struct Pars {
  name : String
} derive(Debug, Eq)

///|
pub fn pars(name : String) -> Pars {
  { name, }
}
