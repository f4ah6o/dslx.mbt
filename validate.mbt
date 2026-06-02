///|
pub fn vald(tree : Tree) -> Vctx {
  { tree, digs: [] }
}

///|
pub fn Vctx::chec(self : Vctx, ok : Bool, msg : String) -> Vctx {
  if ok {
    self
  } else {
    self.fail(msg)
  }
}

///|
pub fn Vctx::warn(self : Vctx, msg : String) -> Vctx {
  let digs = self.digs.copy()
  digs.push(warn(msg))
  { tree: self.tree, digs }
}

///|
pub fn Vctx::fail(self : Vctx, msg : String) -> Vctx {
  let digs = self.digs.copy()
  digs.push(fail(msg))
  { tree: self.tree, digs }
}

///|
pub fn chec(v : Vctx, ok : Bool, msg : String) -> Vctx {
  v.chec(ok, msg)
}

///|
pub fn vspc(value : Dslx) -> Array[Diag] {
  let spec = value.spec
  let digs : Array[Diag] = []
  if spec.name.length() == 0 {
    digs.push(fail("empty spec name"))
  } else if !vidx(spec.name) {
    digs.push(fail("invalid generated name").hint("spec:" + spec.name))
  }
  if spec.nods.length() == 0 {
    digs.push(warn("spec has no node"))
  }
  if spec.ruls.length() == 0 {
    digs.push(warn("spec has no rule"))
  }
  let nodn : Array[String] = []
  for node in spec.nods {
    if node.name.length() == 0 {
      digs.push(fail("empty node name"))
    } else if !vidx(node.name) {
      digs.push(fail("invalid generated name").hint("node:" + node.name))
    }
    if hasx(nodn, node.name) {
      digs.push(fail("duplicate node name").hint(node.name))
    }
    nodn.push(node.name)
    if node.casx.length() == 0 {
      digs.push(warn("node has no case").hint(node.name))
    }
    let casn : Array[String] = []
    for item in node.casx {
      if item.name.length() == 0 {
        digs.push(fail("empty case name").hint(node.name))
      } else if !vidx(item.name) {
        digs.push(fail("invalid generated name").hint("case:" + item.name))
      }
      if hasx(casn, item.name) {
        digs.push(fail("duplicate case name").hint(node.name + "." + item.name))
      }
      casn.push(item.name)
      if item.flds.length() == 0 {
        digs.push(warn("case has no field").hint(item.name))
      }
      let fldn : Array[String] = []
      for fld in item.flds {
        if fld.name.length() == 0 {
          digs.push(fail("empty field name").hint(item.name))
        } else if !vidx(fld.name) {
          digs.push(fail("invalid generated name").hint("field:" + fld.name))
        }
        if hasx(fldn, fld.name) {
          digs.push(
            fail("duplicate field name").hint(item.name + "." + fld.name),
          )
        }
        fldn.push(fld.name)
      }
    }
  }
  let ruln : Array[String] = []
  for rule in spec.ruls {
    if rule.name.length() == 0 {
      digs.push(fail("empty rule name"))
    } else if !vidx(rule.name) {
      digs.push(fail("invalid generated name").hint("rule:" + rule.name))
    }
    if hasx(ruln, rule.name) {
      digs.push(fail("duplicate rule name").hint(rule.name))
    }
    ruln.push(rule.name)
    if rule.expr is Atom {
      digs.push(warn("rule has no body").hint(rule.name))
    }
    vexx(rule.expr, spec.ruls, digs)
    cyrx(rule.expr, spec.ruls, [rule.name], digs)
  }
  digs
}

///|
fn vexx(expr : Expr, rules : Array[Rule], digs : Array[Diag]) -> Unit {
  match expr {
    Seqx(items) => {
      if items.length() == 0 {
        digs.push(fail("empty seqx").hint("add at least one expression"))
      }
      for item in items {
        vexx(item, rules, digs)
      }
    }
    Altx(items) => {
      if items.length() == 0 {
        digs.push(fail("empty altx").hint("add at least one alternative"))
      }
      for item in items {
        vexx(item, rules, digs)
      }
    }
    Many(item) => vexx(item, rules, digs)
    Optx(item) => vexx(item, rules, digs)
    Rgxx(patt) =>
      if !sprg(patt) {
        digs.push(fail("unsupported rgxx").hint(patt))
      }
    Refx(name) =>
      if name.length() == 0 {
        digs.push(fail("empty refx name"))
      } else if frul(rules, name) is None {
        digs.push(fail("undefined refx").hint(name))
      }
    Litx(_) | Tokn(_) | Atom => ()
  }
}

///|
fn sprg(patt : String) -> Bool {
  patt == "[0-9]+" || patt == "[a-zA-Z_][a-zA-Z0-9_]*"
}

///|
fn vidx(name : String) -> Bool {
  if name.length() == 0 || !nsta(name[0].to_int()) {
    return false
  }
  if keyw(name) {
    return false
  }
  for idx in 1..<name.length() {
    if !nchx(name[idx].to_int()) {
      return false
    }
  }
  true
}

///|
fn keyw(name : String) -> Bool {
  match name {
    "as"
    | "async"
    | "break"
    | "const"
    | "continue"
    | "else"
    | "enum"
    | "false"
    | "fn"
    | "for"
    | "if"
    | "impl"
    | "import"
    | "in"
    | "let"
    | "loop"
    | "match"
    | "mut"
    | "priv"
    | "pub"
    | "return"
    | "struct"
    | "trait"
    | "true"
    | "type"
    | "while" => true
    _ => false
  }
}

///|
fn cyrx(
  expr : Expr,
  rules : Array[Rule],
  stkx : Array[String],
  digs : Array[Diag],
) -> Unit {
  match expr {
    Seqx(items) | Altx(items) =>
      for item in items {
        cyrx(item, rules, stkx, digs)
      }
    Many(item) | Optx(item) => cyrx(item, rules, stkx, digs)
    Refx(name) =>
      if hasx(stkx, name) {
        digs.push(fail("refx cycle").hint(ptxt(stkx, name)))
      } else {
        match frul(rules, name) {
          Some(item) => {
            let next = stkx.copy()
            next.push(name)
            cyrx(item, rules, next, digs)
          }
          None => ()
        }
      }
    Litx(_) | Tokn(_) | Rgxx(_) | Atom => ()
  }
}

///|
fn hasx(items : Array[String], name : String) -> Bool {
  for item in items {
    if item == name {
      return true
    }
  }
  false
}

///|
fn ptxt(stkx : Array[String], name : String) -> String {
  let mut out = ""
  for item in stkx {
    if out.length() > 0 {
      out = out + " -> "
    }
    out = out + item
  }
  if out.length() > 0 {
    out = out + " -> "
  }
  out + name
}

///|
pub fn diag(kind : String, text : String) -> Diag {
  { kind, text, span: None, hint: None }
}

///|
pub fn fail(text : String) -> Diag {
  diag("fail", text)
}

///|
pub fn warn(text : String) -> Diag {
  diag("warn", text)
}

///|
pub fn Diag::span(self : Diag, span : Span) -> Diag {
  { kind: self.kind, text: self.text, span: Some(span), hint: self.hint }
}

///|
pub fn Diag::hint(self : Diag, hint : String) -> Diag {
  { kind: self.kind, text: self.text, span: self.span, hint: Some(hint) }
}

///|
pub fn hint(text : String) -> String {
  text
}
