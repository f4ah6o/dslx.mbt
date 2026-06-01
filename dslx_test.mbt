///|
test "spec builder stores nodes and rules" {
  let spec = @dslx.dslx("sql")
    .node(
      @dslx.node("Expr").case(
        @dslx.case("Lit").fldx(@dslx.fldx("text", "String")),
      ),
    )
    .rule(
      @dslx.rule("expr").body(@dslx.altx([@dslx.tokn("name"), @dslx.litx("*")])),
    )
  inspect(@dslx.name(spec), content="sql")
  inspect(spec.spec.nods.length(), content="1")
  inspect(spec.spec.ruls.length(), content="1")
}

///|
test "parser combinators are expression trees" {
  let expr = @dslx.seqx([
    @dslx.litx("if"),
    @dslx.optx(@dslx.tokn("name")),
    @dslx.many(@dslx.rgxx("[0-9]+")),
  ])
  match expr {
    @dslx.Seqx(items) => inspect(items.length(), content="3")
    _ => inspect("wrong", content="seqx")
  }
}

///|
test "pratt parser stores operator metadata" {
  let p = @dslx.prat()
    .pref("-", 90)
    .infx("+", 10)
    .post("!", 80)
    .atom(@dslx.tokn("num"))
  inspect(p.opsx.length(), content="3")
  match p.atom {
    @dslx.Tokn(value) => inspect(value, content="num")
    _ => inspect("wrong", content="tokn")
  }
}

///|
test "diagnostics carry span and hint" {
  let d = @dslx.fail("expected expr")
    .span(@dslx.span("main.dsl", 4, 8))
    .hint("add an expression")
  inspect(d.kind, content="fail")
  inspect(d.text, content="expected expr")
  match d.hint {
    Some(value) => inspect(value, content="add an expression")
    None => inspect("none", content="some")
  }
}

///|
test "pretty printer renders nested docs" {
  let doc = @dslx.join([
    @dslx.text("fn"),
    @dslx.brkx(),
    @dslx.nest(
      2,
      @dslx.join([@dslx.text("main"), @dslx.line(), @dslx.text("{}")]),
    ),
  ])
  inspect(@dslx.prnt(doc), content="fn main\n  {}")
}

///|
test "codegen returns virtual files" {
  let out = @dslx.emit(@dslx.dslx("sql"))
  inspect(@dslx.mods(out).length(), content="1")
  inspect(@dslx.mods(out)[0].path, content="sql.mbt")
}

///|
test "domain specific builders stay compact" {
  let route = @dslx.rout().litx("user").parm("id").bind("User")
  let sql = @dslx.sqlx()
    .slct(["id", "name"])
    .from(["users"])
    .wher("id = ?")
    .join("posts")
    .grup("id")
    .ordr("name")
    .limt(10)
  let html = @dslx.html()
    .elem("div")
    .attr("id", "root")
    .text("abc")
    .chid(@dslx.html().elem("span"))
  let mach = @dslx.mach()
    .stat("Idle")
    .stat("Load")
    .tran("Fetch")
    .evnt("Start")
    .init("Idle")
  inspect(route.segs.length(), content="3")
  inspect(sql.join.length(), content="1")
  inspect(html.chid.length(), content="1")
  inspect(mach.stat.length(), content="2")
}

///|
test "test dsl uses tstx alias" {
  let item = @dslx.tstx("expr").givn("x").when("parse").chec("ok")
  inspect(item.chec.length(), content="1")
  inspect(item.givn.length(), content="1")
}
