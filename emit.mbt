///|
fn emsp(spec : Spec) -> Emix {
  {
    spec,
    mods: [
      file(path("astx.mbt"), east(spec)),
      file(path("pars.mbt"), eprs(spec)),
      file(path("vald.mbt"), evld(spec)),
      file(path("prnt.mbt"), eprt(spec)),
    ],
  }
}

///|
pub fn emit(value : Dslx) -> Emix {
  emsp(value.spec)
}

///|
pub fn Dslx::emit(self : Dslx) -> Emix {
  emsp(self.spec)
}

///|
pub fn file(path : String, text : String) -> File {
  { path, text }
}

///|
pub fn path(text : String) -> String {
  text
}

///|
pub fn mods(value : Emix) -> Array[File] {
  value.mods
}

///|
fn east(spec : Spec) -> String {
  let mut out = "// generated astx for " + spec.name + "\n"
  for node in spec.nods {
    out = out + "pub(all) enum " + node.name + " {\n"
    for item in node.casx {
      out = out + "  " + item.name + "\n"
    }
    out = out + "} derive(Debug, Eq)\n"
  }
  out
}

///|
fn eprs(spec : Spec) -> String {
  let mut out = "// generated pars for " + spec.name + "\n"
  out = out + "fn generated_spec() -> Dslx {\n"
  out = out + "  " + sspe(spec) + "\n"
  out = out + "}\n"
  for rule in spec.ruls {
    out = out +
      "pub fn " +
      rule.name +
      "(text : String) -> Pout { runx(generated_spec(), " +
      qstr(rule.name) +
      ", text) }\n"
  }
  out
}

///|
fn sspe(spec : Spec) -> String {
  let mut out = "dslx(" + qstr(spec.name) + ")"
  for node in spec.nods {
    out = out + ".node(" + snod(node) + ")"
  }
  for rule in spec.ruls {
    out = out +
      ".rule(rule(" +
      qstr(rule.name) +
      ").body(" +
      sexp(rule.expr) +
      "))"
  }
  out
}

///|
fn snod(node : Node) -> String {
  let mut out = "node(" + qstr(node.name) + ")"
  for item in node.casx {
    out = out + ".case(" + scas(item) + ")"
  }
  out
}

///|
fn scas(item : Case) -> String {
  let mut out = "case(" + qstr(item.name) + ")"
  for fld in item.flds {
    out = out + ".fldx(fldx(" + qstr(fld.name) + ", " + qstr(fld.typx) + "))"
  }
  out
}

///|
fn sexp(expr : Expr) -> String {
  match expr {
    Seqx(items) => "seqx([" + sexa(items) + "])"
    Altx(items) => "altx([" + sexa(items) + "])"
    Many(item) => "many(" + sexp(item) + ")"
    Optx(item) => "optx(" + sexp(item) + ")"
    Litx(text) => "litx(" + qstr(text) + ")"
    Tokn(name) => "tokn(" + qstr(name) + ")"
    Rgxx(patt) => "rgxx(" + qstr(patt) + ")"
    Refx(name) => "refx(" + qstr(name) + ")"
    Atom => "atom()"
  }
}

///|
fn sexa(items : Array[Expr]) -> String {
  let mut out = ""
  let mut i = 0
  for item in items {
    if i > 0 {
      out = out + ", "
    }
    out = out + sexp(item)
    i = i + 1
  }
  out
}

///|
fn qstr(text : String) -> String {
  let mut out = "\""
  let mut posx = 0
  while posx < text.length() {
    let ch = text[posx].to_int()
    if ch == 34 {
      out = out + "\\\""
    } else if ch == 92 {
      out = out + "\\\\"
    } else if ch == 10 {
      out = out + "\\n"
    } else if ch == 13 {
      out = out + "\\r"
    } else if ch == 9 {
      out = out + "\\t"
    } else {
      out = out + text.view(start_offset=posx, end_offset=posx + 1).to_owned()
    }
    posx = posx + 1
  }
  out + "\""
}

///|
fn evld(spec : Spec) -> String {
  "// generated vald for " + spec.name + "\n"
}

///|
fn eprt(spec : Spec) -> String {
  "// generated prnt for " + spec.name + "\n"
}
