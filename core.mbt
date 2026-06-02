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
  Refx(String)
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
pub(all) struct Proj {
  name : String
  dslx : Array[Dslx]
  exmp : Array[File]
  mods : Array[File]
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
pub(all) struct Pout {
  done : Bool
  tree : Tree?
  posx : Int
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
  fn pars(Self, String) -> Pout
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
pub fn proj(name : String) -> Proj {
  { name, dslx: [], exmp: [], mods: [] }
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
