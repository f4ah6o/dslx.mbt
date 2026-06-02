///|
pub fn rule(name : String) -> Rule {
  { name, expr: Atom }
}

///|
pub fn Rule::body(self : Rule, expr : Expr) -> Rule {
  { name: self.name, expr }
}

///|
pub fn body(rule : Rule, expr : Expr) -> Rule {
  rule.body(expr)
}

///|
pub fn seqx(items : Array[Expr]) -> Expr {
  Seqx(items)
}

///|
pub fn altx(items : Array[Expr]) -> Expr {
  Altx(items)
}

///|
pub fn many(item : Expr) -> Expr {
  Many(item)
}

///|
pub fn optx(item : Expr) -> Expr {
  Optx(item)
}

///|
pub fn litx(text : String) -> Expr {
  Litx(text)
}

///|
pub fn tokn(text : String) -> Expr {
  Tokn(text)
}

///|
pub fn rgxx(text : String) -> Expr {
  Rgxx(text)
}

///|
pub fn refx(text : String) -> Expr {
  Refx(text)
}
