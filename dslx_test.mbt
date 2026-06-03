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
test "parser executes sequence with tokens and digits" {
  let expr = @dslx.seqx([
    @dslx.litx("if"),
    @dslx.tokn("name"),
    @dslx.rgxx("[0-9]+"),
  ])
  let out = @dslx.pars(expr, "if user_1 42")
  inspect(out.done, content="true")
  inspect(out.posx, content="12")
  inspect(out.digs.length(), content="0")
  match out.tree {
    Some(tree) => inspect(tree.kids.length(), content="3")
    None => inspect("none", content="tree")
  }
}

///|
test "parser supports alternatives many and optional" {
  let expr = @dslx.seqx([
    @dslx.altx([@dslx.litx("let"), @dslx.litx("var")]),
    @dslx.many(@dslx.rgxx("[0-9]+")),
    @dslx.optx(@dslx.litx(";")),
  ])
  let out = @dslx.pars(expr, "var 1 22 ;")
  inspect(out.done, content="true")
  inspect(out.posx, content="10")
  match out.tree {
    Some(tree) => inspect(tree.kids.length(), content="3")
    None => inspect("none", content="tree")
  }
}

///|
test "runx resolves named rule references" {
  let spec = @dslx.dslx("core")
    .rule(@dslx.rule("name").body(@dslx.rgxx("[a-zA-Z_][a-zA-Z0-9_]*")))
    .rule(
      @dslx.rule("decl").body(
        @dslx.seqx([@dslx.litx("let"), @dslx.refx("name"), @dslx.rgxx("[0-9]+")]),
      ),
    )
  let out = @dslx.runx(spec, "decl", "let alpha_1 42")
  inspect(out.done, content="true")
  inspect(out.posx, content="14")
  inspect(out.digs.length(), content="0")
  match out.tree {
    Some(tree) => inspect(tree.kids[1].kind, content="refx:name")
    None => inspect("none", content="tree")
  }
}

///|
test "validation reports direct refx cycle" {
  let spec = @dslx.dslx("core").rule(@dslx.rule("a").body(@dslx.refx("a")))
  let digs = @dslx.vspc(spec)
  inspect(digs.length(), content="2")
  inspect(digs[1].text, content="refx cycle")
  match digs[1].hint {
    Some(value) => inspect(value, content="a -> a")
    None => inspect("none", content="hint")
  }
}

///|
test "validation reports indirect refx cycle" {
  let spec = @dslx.dslx("core")
    .rule(@dslx.rule("a").body(@dslx.refx("b")))
    .rule(@dslx.rule("b").body(@dslx.refx("a")))
  let digs = @dslx.vspc(spec)
  inspect(digs[1].text, content="refx cycle")
  match digs[1].hint {
    Some(value) => inspect(value, content="a -> b -> a")
    None => inspect("none", content="hint")
  }
}

///|
test "runx fails refx cycle without recursion" {
  let spec = @dslx.dslx("core")
    .rule(@dslx.rule("a").body(@dslx.refx("b")))
    .rule(@dslx.rule("b").body(@dslx.refx("a")))
  let out = @dslx.runx(spec, "a", "")
  inspect(out.done, content="false")
  inspect(out.tree is None, content="true")
  inspect(out.digs[0].text, content="refx cycle")
  match out.digs[0].span {
    Some(span) => inspect(span.from, content="0")
    None => inspect("none", content="span")
  }
  match out.digs[0].hint {
    Some(value) => inspect(value, content="a -> b -> a")
    None => inspect("none", content="hint")
  }
}

///|
test "unsupported rgxx fails validation and parsing" {
  let spec = @dslx.dslx("core").rule(
    @dslx.rule("bad").body(@dslx.rgxx("[a-z]+")),
  )
  let digs = @dslx.vspc(spec)
  inspect(digs[1].text, content="unsupported rgxx")
  let out = @dslx.pars(@dslx.rgxx("[a-z]+"), "[a-z]+")
  inspect(out.done, content="false")
  inspect(out.tree is None, content="true")
  inspect(out.digs[0].text, content="unsupported pattern")
  match out.digs[0].span {
    Some(span) => inspect(span.from, content="0")
    None => inspect("none", content="span")
  }
}

///|
test "validator reports undefined refx empty grammar and duplicates" {
  let spec = @dslx.dslx("core")
    .node(
      @dslx.node("Expr")
      .case(@dslx.case("Lit").fldx(@dslx.fldx("text", "String")))
      .case(
        @dslx.case("Lit")
        .fldx(@dslx.fldx("text", "String"))
        .fldx(@dslx.fldx("text", "String")),
      ),
    )
    .node(@dslx.node("Expr"))
    .rule(@dslx.rule("expr").body(@dslx.seqx([])))
    .rule(@dslx.rule("expr").body(@dslx.altx([])))
    .rule(@dslx.rule("decl").body(@dslx.refx("missing")))
  let digs = @dslx.vspc(spec)
  inspect(digs.length(), content="8")
  inspect(digs[0].text, content="duplicate case name")
  inspect(digs[1].text, content="duplicate field name")
  inspect(digs[2].text, content="duplicate node name")
  inspect(digs[4].text, content="empty seqx")
  inspect(digs[5].text, content="duplicate rule name")
  inspect(digs[6].text, content="empty altx")
  inspect(digs[7].text, content="undefined refx")
}

///|
test "parser reports failed literal" {
  let out = @dslx.pars(@dslx.litx("if"), "else")
  inspect(out.done, content="false")
  inspect(out.tree is None, content="true")
  inspect(out.digs.length(), content="1")
  match out.digs[0].span {
    Some(span) => inspect(span.from, content="0")
    None => inspect("none", content="span")
  }
}

///|
test "strict parse allows only trailing whitespace" {
  let ok = @dslx.pars(@dslx.litx("if"), "  if \n\t")
  inspect(ok.done, content="true")
  inspect(ok.posx, content="7")
  inspect(ok.digs.length(), content="0")
  match ok.tree {
    Some(tree) => inspect(tree.text, content="if")
    None => inspect("none", content="tree")
  }

  let bad = @dslx.pars(@dslx.litx("if"), "if else")
  inspect(bad.done, content="false")
  inspect(bad.tree is None, content="true")
  inspect(bad.digs.length(), content="1")
  inspect(bad.digs[0].text, content="unexpected input")
  match bad.digs[0].span {
    Some(span) => {
      inspect(span.from, content="3")
      inspect(span.upto, content="3")
    }
    None => inspect("none", content="span")
  }
}

///|
test "parse failures include spans" {
  let token = @dslx.pars(@dslx.tokn("name"), "  123")
  inspect(token.digs[0].text, content="expected token")
  match token.digs[0].span {
    Some(span) => inspect(span.from, content="2")
    None => inspect("none", content="span")
  }

  let regex = @dslx.pars(@dslx.rgxx("[0-9]+"), "abc")
  inspect(regex.digs[0].text, content="expected pattern")
  match regex.digs[0].span {
    Some(span) => inspect(span.from, content="0")
    None => inspect("none", content="span")
  }

  let spec = @dslx.dslx("core").rule(
    @dslx.rule("decl").body(@dslx.refx("name")),
  )
  let refx = @dslx.runx(spec, "decl", "")
  inspect(refx.digs[0].text, content="undefined rule")
  match refx.digs[0].span {
    Some(span) => inspect(span.from, content="0")
    None => inspect("none", content="span")
  }

  let start = @dslx.runx(spec, "miss", "")
  inspect(start.digs[0].text, content="unknown start rule")
  match start.digs[0].span {
    Some(span) => inspect(span.from, content="0")
    None => inspect("none", content="span")
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
  let out = @dslx.emit(
    @dslx.dslx("sql").rule(@dslx.rule("expr").body(@dslx.litx("if"))),
  )
  inspect(@dslx.mods(out).length(), content="4")
  inspect(@dslx.mods(out)[0].path, content="astx.mbt")
  inspect(
    @dslx.mods(out)[1].text,
    content=(
      #|// generated pars for sql
      #|fn generated_spec() -> Dslx {
      #|  dslx("sql").rule(rule("expr").body(litx("if")))
      #|}
      #|pub fn expr(text : String) -> Pout { runx(generated_spec(), "expr", text) }
      #|
    ),
  )
}

///|
test "codegen serializes rule expressions with refx" {
  let out = @dslx.emit(
    @dslx.dslx("core")
    .rule(@dslx.rule("name").body(@dslx.rgxx("[a-zA-Z_][a-zA-Z0-9_]*")))
    .rule(
      @dslx.rule("decl").body(
        @dslx.seqx([@dslx.litx("let"), @dslx.refx("name")]),
      ),
    ),
  )
  inspect(
    @dslx.mods(out)[1].text,
    content=(
      #|// generated pars for core
      #|fn generated_spec() -> Dslx {
      #|  dslx("core").rule(rule("name").body(rgxx("[a-zA-Z_][a-zA-Z0-9_]*"))).rule(rule("decl").body(seqx([litx("let"), refx("name")])))
      #|}
      #|pub fn name(text : String) -> Pout { runx(generated_spec(), "name", text) }
      #|pub fn decl(text : String) -> Pout { runx(generated_spec(), "decl", text) }
      #|
    ),
  )
}

///|
test "codegen serializes generated spec with ast nodes" {
  let out = @dslx.emit(
    @dslx.dslx("core")
    .node(
      @dslx.node("Expr").case(
        @dslx.case("Lit").fldx(@dslx.fldx("text", "String")),
      ),
    )
    .rule(@dslx.rule("expr").body(@dslx.tokn("name"))),
  )
  inspect(
    @dslx.mods(out)[1].text,
    content=(
      #|// generated pars for core
      #|fn generated_spec() -> Dslx {
      #|  dslx("core").node(node("Expr").case(case("Lit").fldx(fldx("text", "String")))).rule(rule("expr").body(tokn("name")))
      #|}
      #|pub fn expr(text : String) -> Pout { runx(generated_spec(), "expr", text) }
      #|
    ),
  )
}

///|
test "validation rejects names that generated MoonBit cannot emit" {
  let spec = @dslx.dslx("bad-name")
    .node(
      @dslx.node("1Expr").case(
        @dslx.case("Bad-Case").fldx(@dslx.fldx("field name", "String")),
      ),
    )
    .rule(@dslx.rule("let-name").body(@dslx.litx("x")))
    .rule(@dslx.rule("let").body(@dslx.litx("y")))
  let digs = @dslx.vspc(spec)
  inspect(digs.length(), content="6")
  inspect(digs[0].text, content="invalid generated name")
  match digs[0].hint {
    Some(value) => inspect(value, content="spec:bad-name")
    None => inspect("none", content="hint")
  }
  match digs[4].hint {
    Some(value) => inspect(value, content="rule:let-name")
    None => inspect("none", content="hint")
  }
  match digs[5].hint {
    Some(value) => inspect(value, content="rule:let")
    None => inspect("none", content="hint")
  }
}

///|
test "spec validation reports structural issues" {
  let spec = @dslx.dslx("").node(@dslx.node("Expr")).rule(@dslx.rule("expr"))
  let digs = @dslx.vspc(spec)
  inspect(digs.length(), content="3")
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

///|
test "project pack returns deterministic virtual files" {
  let prj = @dslx.proj("family")
    .file(@dslx.file("README.md", "# family\n"))
    .exmp(
      @dslx.file(
        "examples/fwd.dsl", "schema User state Draft state Released entity User { id:int } rule hasEntity: custom entityCheck transition submit: Draft -> Released effect save rule hasEntity\n",
      ),
    )
    .dslx(@dslx.dslx("Tiny").rule(@dslx.rule("main").body(@dslx.litx("ok"))))
  let files = @dslx.pack(prj)
  inspect(files.length(), content="6")
  inspect(files[0].path, content="README.md")
  inspect(files[1].path, content="examples/fwd.dsl")
  inspect(files[2].path, content="Tiny/astx.mbt")
  inspect(files[3].path, content="Tiny/pars.mbt")
  inspect(files[4].path, content="Tiny/vald.mbt")
  inspect(files[5].path, content="Tiny/prnt.mbt")
  let again = @dslx.pack(prj)
  inspect(again == files, content="true")
}

///|
test "project lookup parse and example checks route through specs" {
  let fwd_file = @dslx.file(
    "examples/fwd.dsl", "schema User state Draft state Released entity User { id:int name:text } rule hasEntity: custom entityCheck transition submit: Draft -> Released effect save rule hasEntity\n",
  )
  let flow_file = @dslx.file(
    "examples/flow.dsl", "flow Build node Fetch Fetch -> Save",
  )
  let prj = @dslx.proj("family")
    .exmp(fwd_file)
    .exmp(flow_file)
    .dslx(@dslx.fwds())
    .dslx(@dslx.wflw())
    .dslx(@dslx.domn())
    .dslx(@dslx.n8nx())
  match @dslx.fspc(prj, "Fwd") {
    Some(spec) => inspect(@dslx.name(spec), content="Fwd")
    None => inspect("none", content="Fwd")
  }
  inspect(@dslx.fspc(prj, "Missing") is None, content="true")
  inspect(@dslx.runp(prj, "Fwd", "sche", fwd_file.text).done, content="true")
  inspect(@dslx.runp(prj, "Wflw", "flow", flow_file.text).done, content="true")
  inspect(@dslx.chex(prj, "Fwd", "sche", fwd_file).length(), content="0")
  let missing = @dslx.runp(prj, "Missing", "sche", fwd_file.text)
  inspect(missing.done, content="false")
  inspect(missing.digs[0].text, content="unknown project spec")
  match missing.digs[0].hint {
    Some(value) => inspect(value, content="Missing")
    None => inspect("none", content="hint")
  }
  let bad = @dslx.chex(prj, "Fwd", "sche", @dslx.file("bad.dsl", "not schema"))
  inspect(bad.length() > 0, content="true")
}

///|
test "project validation reports duplicate specs and virtual paths" {
  let prj = @dslx.proj("family")
    .file(@dslx.file("dup.mbt", "a"))
    .exmp(@dslx.file("dup.mbt", "b"))
    .dslx(@dslx.dslx("Same").rule(@dslx.rule("main").body(@dslx.litx("x"))))
    .dslx(@dslx.dslx("Same").rule(@dslx.rule("main").body(@dslx.litx("y"))))
  let digs = @dslx.vprj(prj)
  inspect(count_diag(digs, "duplicate spec name"), content="1")
  inspect(count_diag(digs, "duplicate file path"), content="5")
  match digs[digs.length() - 5].hint {
    Some(value) => inspect(value, content="dup.mbt")
    None => inspect("none", content="hint")
  }
}

///|
test "family example specs validate and parse their roots" {
  let fwd = @dslx.fwds()
  let flow = @dslx.wflw()
  let domn = @dslx.domn()
  let n8n = @dslx.n8nx()
  inspect(@dslx.vspc(fwd).length(), content="0")
  inspect(@dslx.vspc(flow).length(), content="0")
  inspect(@dslx.vspc(domn).length(), content="0")
  inspect(@dslx.vspc(n8n).length(), content="0")
  inspect(
    @dslx.runx(
      fwd, "sche", "schema User state Draft state Released entity User { id:int name:text } rule hasEntity: custom entityCheck transition submit: Draft -> Released effect save rule hasEntity",
    ).done,
    content="true",
  )
  inspect(@dslx.runx(fwd, "sche", "schema User id:blob").done, content="false")
  inspect(
    @dslx.runx(flow, "flow", "flow Build node Fetch Fetch -> Save").done,
    content="true",
  )
  inspect(
    @dslx.runx(domn, "domn", "domain Sales entity Order process Ship Order").done,
    content="true",
  )
  inspect(
    @dslx.runx(n8n, "n8nw", "workflow Sync step Pull http Pull => Push").done,
    content="true",
  )
}
