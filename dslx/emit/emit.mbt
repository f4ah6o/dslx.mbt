///|
pub(all) struct Emit {
  text : String
} derive(Debug, Eq)

///|
pub fn emit(text : String) -> Emit {
  { text, }
}
