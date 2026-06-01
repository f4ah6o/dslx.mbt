///|
pub(all) struct Span {
  file : String
  from : Int
  upto : Int
} derive(Debug, Eq)

///|
pub(all) enum Expr {
  Seqx(Array[Expr])
  Altx(Array[Expr])
  Many(Expr)
  Optx(Expr)
  Litx(String)
  Tokn(String)
  Rgxx(String)
  Atom
} derive(Debug, Eq)

///|
pub(all) struct Fldx {
  name : String
  typx : String
} derive(Debug, Eq)

///|
pub(all) struct Case {
  name : String
  flds : Array[Fldx]
} derive(Debug, Eq)

///|
pub(all) struct Node {
  name : String
  casx : Array[Case]
} derive(Debug, Eq)

///|
pub(all) struct Rule {
  name : String
  expr : Expr
} derive(Debug, Eq)

///|
pub(all) struct Oper {
  kind : String
  text : String
  prec : Int
} derive(Debug, Eq)

///|
pub(all) struct Prat {
  opsx : Array[Oper]
  atom : Expr
} derive(Debug, Eq)

///|
pub(all) struct Tree {
  kind : String
  text : String
  kids : Array[Tree]
  span : Span?
} derive(Debug, Eq)

///|
pub(all) struct Diag {
  kind : String
  text : String
  span : Span?
  hint : String?
} derive(Debug, Eq)

///|
pub(all) enum Docx {
  Text(String)
  Line
  Join(Array[Docx])
  Grup(Docx)
  Nest(Int, Docx)
  Brkx
} derive(Debug, Eq)

///|
pub(all) struct File {
  path : String
  text : String
} derive(Debug, Eq)

///|
pub(all) struct Emix {
  spec : Spec
  mods : Array[File]
} derive(Debug, Eq)

///|
pub(all) struct Spec {
  name : String
  nods : Array[Node]
  ruls : Array[Rule]
  digs : Array[Diag]
} derive(Debug, Eq)

///|
pub(all) struct Dslx {
  spec : Spec
} derive(Debug, Eq)

///|
pub(all) struct Vctx {
  tree : Tree
  digs : Array[Diag]
} derive(Debug, Eq)

///|
pub(all) struct Rout {
  segs : Array[String]
} derive(Debug, Eq)

///|
pub(all) struct Sqlx {
  cols : Array[String]
  from : Array[String]
  wher : String?
  join : Array[String]
  grup : Array[String]
  ordr : Array[String]
  limt : Int?
} derive(Debug, Eq)

///|
pub(all) struct Html {
  name : String
  atrs : Array[(String, String)]
  text : String?
  chid : Array[Html]
} derive(Debug, Eq)

///|
pub(all) struct Mach {
  stat : Array[String]
  tran : Array[String]
  evnt : Array[String]
  init : String?
} derive(Debug, Eq)

///|
pub(all) struct Tstx {
  name : String
  givn : Array[String]
  when : Array[String]
  chec : Array[String]
} derive(Debug, Eq)

///|
pub trait Pars {
  fn pars(Self, String) -> Tree?
}

///|
pub trait Vald {
  fn vald(Self, Tree) -> Array[Diag]
}

///|
pub trait Prnt {
  fn prnt(Self) -> Docx
}

///|
pub trait Emit {
  fn emit(Self) -> Array[File]
}

///|
pub fn spec(name : String) -> Spec {
  { name, nods: [], ruls: [], digs: [] }
}

///|
pub fn dslx(name : String) -> Dslx {
  { spec: spec(name) }
}

///|
pub fn name(value : Dslx) -> String {
  value.spec.name
}

///|
pub fn node(name : String) -> Node {
  { name, casx: [] }
}

///|
pub fn case(name : String) -> Case {
  { name, flds: [] }
}

///|
pub fn fldx(name : String, typx : String) -> Fldx {
  { name, typx }
}

///|
pub fn Case::fldx(self : Case, fld : Fldx) -> Case {
  let flds = self.flds.copy()
  flds.push(fld)
  { name: self.name, flds }
}

///|
pub fn Node::case(self : Node, item : Case) -> Node {
  let casx = self.casx.copy()
  casx.push(item)
  { name: self.name, casx }
}

///|
pub fn Dslx::node(self : Dslx, item : Node) -> Dslx {
  let nods = self.spec.nods.copy()
  nods.push(item)
  {
    spec: {
      name: self.spec.name,
      nods,
      ruls: self.spec.ruls,
      digs: self.spec.digs,
    },
  }
}

///|
pub fn Dslx::rule(self : Dslx, item : Rule) -> Dslx {
  let ruls = self.spec.ruls.copy()
  ruls.push(item)
  {
    spec: {
      name: self.spec.name,
      nods: self.spec.nods,
      ruls,
      digs: self.spec.digs,
    },
  }
}

///|
pub fn Dslx::diag(self : Dslx, item : Diag) -> Dslx {
  let digs = self.spec.digs.copy()
  digs.push(item)
  {
    spec: {
      name: self.spec.name,
      nods: self.spec.nods,
      ruls: self.spec.ruls,
      digs,
    },
  }
}

///|
pub fn tree(
  kind : String,
  text : String,
  kids? : Array[Tree] = [],
  span? : Span,
) -> Tree {
  { kind, text, kids, span }
}

///|
pub fn span(file : String, from : Int, upto : Int) -> Span {
  { file, from, upto }
}

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
pub fn atom() -> Expr {
  Atom
}

///|
pub fn prat() -> Prat {
  { opsx: [], atom: Atom }
}

///|
pub fn Prat::pref(self : Prat, text : String, prec : Int) -> Prat {
  let opsx = self.opsx.copy()
  opsx.push({ kind: "pref", text, prec })
  { opsx, atom: self.atom }
}

///|
pub fn Prat::infx(self : Prat, text : String, prec : Int) -> Prat {
  let opsx = self.opsx.copy()
  opsx.push({ kind: "infx", text, prec })
  { opsx, atom: self.atom }
}

///|
pub fn Prat::post(self : Prat, text : String, prec : Int) -> Prat {
  let opsx = self.opsx.copy()
  opsx.push({ kind: "post", text, prec })
  { opsx, atom: self.atom }
}

///|
pub fn Prat::atom(self : Prat, expr : Expr) -> Prat {
  { opsx: self.opsx, atom: expr }
}

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

///|
fn emsp(spec : Spec) -> Emix {
  let content = "dslx " + spec.name + "\n"
  { spec, mods: [file(path(spec.name + ".mbt"), content)] }
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
pub fn Rout::litx(self : Rout, text : String) -> Rout {
  let segs = self.segs.copy()
  segs.push("litx:" + text)
  { segs, }
}

///|
pub fn Rout::parm(self : Rout, name : String) -> Rout {
  let segs = self.segs.copy()
  segs.push("parm:" + name)
  { segs, }
}

///|
pub fn Rout::bind(self : Rout, name : String) -> Rout {
  let segs = self.segs.copy()
  segs.push("bind:" + name)
  { segs, }
}

///|
pub fn rout() -> Rout {
  { segs: [] }
}

///|
pub fn parm(text : String) -> String {
  text
}

///|
pub fn bind(text : String) -> String {
  text
}

///|
pub fn sqlx() -> Sqlx {
  { cols: [], from: [], wher: None, join: [], grup: [], ordr: [], limt: None }
}

///|
pub fn Sqlx::slct(self : Sqlx, cols : Array[String]) -> Sqlx {
  {
    cols,
    from: self.from,
    wher: self.wher,
    join: self.join,
    grup: self.grup,
    ordr: self.ordr,
    limt: self.limt,
  }
}

///|
pub fn Sqlx::from(self : Sqlx, tbls : Array[String]) -> Sqlx {
  {
    cols: self.cols,
    from: tbls,
    wher: self.wher,
    join: self.join,
    grup: self.grup,
    ordr: self.ordr,
    limt: self.limt,
  }
}

///|
pub fn Sqlx::wher(self : Sqlx, cond : String) -> Sqlx {
  {
    cols: self.cols,
    from: self.from,
    wher: Some(cond),
    join: self.join,
    grup: self.grup,
    ordr: self.ordr,
    limt: self.limt,
  }
}

///|
pub fn Sqlx::join(self : Sqlx, tbl : String) -> Sqlx {
  let join = self.join.copy()
  join.push(tbl)
  {
    cols: self.cols,
    from: self.from,
    wher: self.wher,
    join,
    grup: self.grup,
    ordr: self.ordr,
    limt: self.limt,
  }
}

///|
pub fn Sqlx::grup(self : Sqlx, col : String) -> Sqlx {
  let grup = self.grup.copy()
  grup.push(col)
  {
    cols: self.cols,
    from: self.from,
    wher: self.wher,
    join: self.join,
    grup,
    ordr: self.ordr,
    limt: self.limt,
  }
}

///|
pub fn Sqlx::ordr(self : Sqlx, col : String) -> Sqlx {
  let ordr = self.ordr.copy()
  ordr.push(col)
  {
    cols: self.cols,
    from: self.from,
    wher: self.wher,
    join: self.join,
    grup: self.grup,
    ordr,
    limt: self.limt,
  }
}

///|
pub fn Sqlx::limt(self : Sqlx, limt : Int) -> Sqlx {
  {
    cols: self.cols,
    from: self.from,
    wher: self.wher,
    join: self.join,
    grup: self.grup,
    ordr: self.ordr,
    limt: Some(limt),
  }
}

///|
pub fn slct(cols : Array[String]) -> Array[String] {
  cols
}

///|
pub fn from(tbls : Array[String]) -> Array[String] {
  tbls
}

///|
pub fn wher(cond : String) -> String {
  cond
}

///|
pub fn ordr(col : String) -> String {
  col
}

///|
pub fn limt(n : Int) -> Int {
  n
}

///|
pub fn html() -> Html {
  { name: "", atrs: [], text: None, chid: [] }
}

///|
pub fn Html::elem(self : Html, name : String) -> Html {
  { name, atrs: self.atrs, text: self.text, chid: self.chid }
}

///|
pub fn Html::attr(self : Html, name : String, value : String) -> Html {
  let atrs = self.atrs.copy()
  atrs.push((name, value))
  { name: self.name, atrs, text: self.text, chid: self.chid }
}

///|
pub fn Html::text(self : Html, value : String) -> Html {
  { name: self.name, atrs: self.atrs, text: Some(value), chid: self.chid }
}

///|
pub fn Html::chid(self : Html, item : Html) -> Html {
  let chid = self.chid.copy()
  chid.push(item)
  { name: self.name, atrs: self.atrs, text: self.text, chid }
}

///|
pub fn elem(name : String) -> String {
  name
}

///|
pub fn attr(name : String, value : String) -> (String, String) {
  (name, value)
}

///|
pub fn chid(item : Html) -> Html {
  item
}

///|
pub fn mach() -> Mach {
  { stat: [], tran: [], evnt: [], init: None }
}

///|
pub fn Mach::stat(self : Mach, name : String) -> Mach {
  let stat = self.stat.copy()
  stat.push(name)
  { stat, tran: self.tran, evnt: self.evnt, init: self.init }
}

///|
pub fn Mach::tran(self : Mach, name : String) -> Mach {
  let tran = self.tran.copy()
  tran.push(name)
  { stat: self.stat, tran, evnt: self.evnt, init: self.init }
}

///|
pub fn Mach::evnt(self : Mach, name : String) -> Mach {
  let evnt = self.evnt.copy()
  evnt.push(name)
  { stat: self.stat, tran: self.tran, evnt, init: self.init }
}

///|
pub fn Mach::init(self : Mach, name : String) -> Mach {
  { stat: self.stat, tran: self.tran, evnt: self.evnt, init: Some(name) }
}

///|
pub fn stat(name : String) -> String {
  name
}

///|
pub fn tran(name : String) -> String {
  name
}

///|
pub fn evnt(name : String) -> String {
  name
}

///|

///|
pub fn tstx(name : String) -> Tstx {
  { name, givn: [], when: [], chec: [] }
}

///|
pub fn Tstx::givn(self : Tstx, text : String) -> Tstx {
  let givn = self.givn.copy()
  givn.push(text)
  { name: self.name, givn, when: self.when, chec: self.chec }
}

///|
pub fn Tstx::when(self : Tstx, text : String) -> Tstx {
  let when = self.when.copy()
  when.push(text)
  { name: self.name, givn: self.givn, when, chec: self.chec }
}

///|
pub fn Tstx::chec(self : Tstx, text : String) -> Tstx {
  let chec = self.chec.copy()
  chec.push(text)
  { name: self.name, givn: self.givn, when: self.when, chec }
}

///|
pub fn givn(text : String) -> String {
  text
}

///|
pub fn when(text : String) -> String {
  text
}
