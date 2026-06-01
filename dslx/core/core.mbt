///|
pub(all) struct Core {
  name : String
} derive(Debug, Eq)

///|
pub fn core(name : String) -> Core {
  { name, }
}
