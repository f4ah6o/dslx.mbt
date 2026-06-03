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
pub fn fwds() -> Dslx {
  dslx("Fwd")
  .node(
    node("Sche")
    .case(
      case("Root")
      .fldx(fldx("name", "String"))
      .fldx(fldx("items", "Array[String]")),
    )
    .case(case("State").fldx(fldx("name", "String")))
    .case(
      case("Field").fldx(fldx("name", "String")).fldx(fldx("typx", "String")),
    )
    .case(
      case("Entity")
      .fldx(fldx("name", "String"))
      .fldx(fldx("fields", "Array[String]")),
    )
    .case(
      case("Transition")
      .fldx(fldx("name", "String"))
      .fldx(fldx("from", "String"))
      .fldx(fldx("upto", "String")),
    )
    .case(case("Effect").fldx(fldx("name", "String")))
    .case(
      case("Rule")
      .fldx(fldx("name", "String"))
      .fldx(fldx("kind", "String"))
      .fldx(fldx("body", "String")),
    ),
  )
  .rule(rule("name").body(rgxx("[a-zA-Z_][a-zA-Z0-9_]*")))
  .rule(rule("typx").body(altx([litx("text"), litx("int"), litx("bool")])))
  .rule(rule("fldx").body(seqx([refx("name"), litx(":"), refx("typx")])))
  .rule(rule("stat").body(seqx([litx("state"), refx("name")])))
  .rule(
    rule("enty").body(
      seqx([
        litx("entity"),
        refx("name"),
        litx("{"),
        many(refx("fldx")),
        litx("}"),
      ]),
    ),
  )
  .rule(
    rule("tref").body(
      altx([
        seqx([litx("rule"), refx("name")]),
        seqx([litx("effect"), refx("name")]),
      ]),
    ),
  )
  .rule(
    rule("tran").body(
      seqx([
        litx("transition"),
        refx("name"),
        litx(":"),
        refx("name"),
        litx("->"),
        refx("name"),
        many(refx("tref")),
      ]),
    ),
  )
  .rule(rule("effx").body(seqx([litx("effect"), refx("name")])))
  .rule(
    rule("rkind").body(
      altx([
        seqx([litx("preset"), refx("name")]),
        seqx([litx("custom"), refx("name")]),
      ]),
    ),
  )
  .rule(
    rule("rulx").body(
      seqx([litx("rule"), refx("name"), litx(":"), refx("rkind")]),
    ),
  )
  .rule(
    rule("item").body(
      altx([
        refx("stat"),
        refx("enty"),
        refx("tran"),
        refx("effx"),
        refx("rulx"),
      ]),
    ),
  )
  .rule(
    rule("sche").body(seqx([litx("schema"), refx("name"), many(refx("item"))])),
  )
}

///|
pub fn wflw() -> Dslx {
  dslx("Wflw")
  .node(
    node("Flow")
    .case(case("Node").fldx(fldx("name", "String")))
    .case(
      case("Edge").fldx(fldx("from", "String")).fldx(fldx("upto", "String")),
    ),
  )
  .rule(rule("name").body(rgxx("[a-zA-Z_][a-zA-Z0-9_]*")))
  .rule(rule("node").body(seqx([litx("node"), refx("name")])))
  .rule(rule("edge").body(seqx([refx("name"), litx("->"), refx("name")])))
  .rule(
    rule("flow").body(
      seqx([
        litx("flow"),
        refx("name"),
        many(altx([refx("node"), refx("edge")])),
      ]),
    ),
  )
}

///|
pub fn domn() -> Dslx {
  dslx("Domn")
  .node(
    node("Domn")
    .case(case("Enty").fldx(fldx("name", "String")))
    .case(case("Proc").fldx(fldx("name", "String"))),
  )
  .rule(rule("name").body(rgxx("[a-zA-Z_][a-zA-Z0-9_]*")))
  .rule(rule("enty").body(seqx([litx("entity"), refx("name")])))
  .rule(
    rule("proc").body(seqx([litx("process"), refx("name"), many(refx("name"))])),
  )
  .rule(
    rule("domn").body(
      seqx([
        litx("domain"),
        refx("name"),
        many(altx([refx("enty"), refx("proc")])),
      ]),
    ),
  )
}

///|
pub fn n8nx() -> Dslx {
  dslx("N8nx")
  .node(
    node("N8nw")
    .case(
      case("Step").fldx(fldx("name", "String")).fldx(fldx("kind", "String")),
    )
    .case(
      case("Wire").fldx(fldx("from", "String")).fldx(fldx("upto", "String")),
    ),
  )
  .rule(rule("name").body(rgxx("[a-zA-Z_][a-zA-Z0-9_]*")))
  .rule(rule("step").body(seqx([litx("step"), refx("name"), refx("name")])))
  .rule(rule("wire").body(seqx([refx("name"), litx("=>"), refx("name")])))
  .rule(
    rule("n8nw").body(
      seqx([
        litx("workflow"),
        refx("name"),
        many(altx([refx("step"), refx("wire")])),
      ]),
    ),
  )
}

///|
pub fn givn(text : String) -> String {
  text
}

///|
pub fn when(text : String) -> String {
  text
}
