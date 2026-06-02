///|
pub fn prnt(doc : Docx) -> String {
  rend(doc, 0)
}

///|
pub fn grup(doc : Docx) -> Docx {
  Grup(doc)
}

///|
pub fn line() -> Docx {
  Line
}

///|
pub fn join(items : Array[Docx]) -> Docx {
  Join(items)
}

///|
pub fn nest(size : Int, doc : Docx) -> Docx {
  Nest(size, doc)
}

///|
pub fn brkx() -> Docx {
  Brkx
}

///|
pub fn text(value : String) -> Docx {
  Text(value)
}

///|
fn rend(doc : Docx, indt : Int) -> String {
  match doc {
    Text(value) => value
    Line => "\n" + padx(indt)
    Brkx => " "
    Grup(inner) => rend(inner, indt)
    Nest(size, inner) => rend(inner, indt + size)
    Join(items) => {
      let mut out = ""
      for item in items {
        out = out + rend(item, indt)
      }
      out
    }
  }
}

///|
fn padx(size : Int) -> String {
  let mut out = ""
  for _ in 0..<size {
    out = out + " "
  }
  out
}
