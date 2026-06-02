///|
struct PairSeed {
  left : Int
  right : Int
} derive(@quickcheck.Arbitrary, Debug)

///|
fn pidx(value : Int, size : Int) -> Int {
  let rem = value % size
  if rem < 0 {
    rem + size
  } else {
    rem
  }
}

///|
fn letter(value : Int) -> String {
  let chars = [
    "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p",
    "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "A", "B", "C", "D", "E", "F",
    "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V",
    "W", "X", "Y", "Z", "_",
  ]
  chars[pidx(value, chars.length())]
}

///|
fn name_char(value : Int) -> String {
  let chars = [
    "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p",
    "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "A", "B", "C", "D", "E", "F",
    "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V",
    "W", "X", "Y", "Z", "_", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
  ]
  chars[pidx(value, chars.length())]
}

///|
fn digit(value : Int) -> String {
  let chars = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
  chars[pidx(value, chars.length())]
}

///|
fn valid_ident(value : Int) -> String {
  letter(value) +
  name_char(value / 3) +
  name_char(value / 7) +
  name_char(value / 11)
}

///|
fn digit_text(value : Int) -> String {
  digit(value) + digit(value / 5) + digit(value / 17)
}

///|
fn invalid_name(value : Int) -> String {
  let items = ["", "1bad", "bad-name", "field name", "let", "fn", "bad.name"]
  items[pidx(value, items.length())]
}

///|
fn has_diag(digs : Array[@dslx.Diag], text : String, hint : String) -> Bool {
  for diag in digs {
    if diag.text == text && diag.hint == Some(hint) {
      return true
    }
  }
  false
}

///|
fn count_diag(digs : Array[@dslx.Diag], text : String) -> Int {
  let mut count = 0
  for diag in digs {
    if diag.text == text {
      count = count + 1
    }
  }
  count
}

///|
fn file_text(files : Array[@dslx.File], path : String) -> String {
  for file in files {
    if file.path == path {
      return file.text
    }
  }
  ""
}

///|
fn assert_done(out : @dslx.Pout, expected_posx : Int) -> Unit {
  guard out.done else { panic() }
  guard out.tree is Some(_) else { panic() }
  guard out.posx == expected_posx else { panic() }
  guard out.digs.length() == 0 else { panic() }
}

///|
test "quickcheck valid identifiers parse as token and identifier regex" {
  let seeds : Array[Int] = @quickcheck.samples(300)
  for seed in seeds {
    let input = valid_ident(seed)
    let tok = @dslx.pars(@dslx.tokn("name"), input)
    assert_done(tok, input.length())
    match tok.tree {
      Some(tree) => {
        guard tree.kind == "name" else { panic() }
        guard tree.text == input else { panic() }
      }
      None => panic()
    }
    let rgx = @dslx.pars(@dslx.rgxx("[a-zA-Z_][a-zA-Z0-9_]*"), input)
    assert_done(rgx, input.length())
    match rgx.tree {
      Some(tree) => {
        guard tree.kind == "rgxx" else { panic() }
        guard tree.text == input else { panic() }
      }
      None => panic()
    }
  }
}

///|
test "quickcheck digit strings parse with trailing whitespace" {
  let seeds : Array[Int] = @quickcheck.samples(300)
  for seed in seeds {
    let digits = digit_text(seed)
    let input = digits + " \n\t"
    let out = @dslx.pars(@dslx.rgxx("[0-9]+"), input)
    assert_done(out, input.length())
    match out.tree {
      Some(tree) => {
        guard tree.kind == "rgxx" else { panic() }
        guard tree.text == digits else { panic() }
      }
      None => panic()
    }
  }
}

///|
test "quickcheck literal strict parsing rejects non whitespace suffix" {
  let seeds : Array[Int] = @quickcheck.samples(200)
  for seed in seeds {
    let suffix = valid_ident(seed)
    let out = @dslx.pars(@dslx.litx("if"), "if" + suffix)
    guard !out.done else { panic() }
    guard out.tree is None else { panic() }
    guard out.digs.length() == 1 else { panic() }
    guard out.digs[0].text == "unexpected input" else { panic() }
    match out.digs[0].span {
      Some(span) => {
        guard span.from == 2 else { panic() }
      }
      None => panic()
    }
  }
}

///|
test "quickcheck combinator tree shape and positions stay stable" {
  let seeds : Array[PairSeed] = @quickcheck.samples(240)
  for seed in seeds {
    let ident = valid_ident(seed.left)
    let digits = digit_text(seed.right)
    let seq = @dslx.pars(
      @dslx.seqx([@dslx.litx("let"), @dslx.tokn("name"), @dslx.rgxx("[0-9]+")]),
      "let " + ident + " " + digits,
    )
    assert_done(seq, 4 + ident.length() + 1 + digits.length())
    match seq.tree {
      Some(tree) => {
        guard tree.kind == "seqx" else { panic() }
        guard tree.kids.length() == 3 else { panic() }
        guard tree.kids[1].text == ident else { panic() }
        guard tree.kids[2].text == digits else { panic() }
      }
      None => panic()
    }

    let alt = @dslx.pars(
      @dslx.altx([@dslx.litx("let"), @dslx.litx("var")]),
      "var",
    )
    assert_done(alt, 3)
    match alt.tree {
      Some(tree) => {
        guard tree.kind == "altx" else { panic() }
        guard tree.kids.length() == 1 else { panic() }
        guard tree.kids[0].text == "var" else { panic() }
      }
      None => panic()
    }

    let many = @dslx.pars(
      @dslx.many(@dslx.rgxx("[0-9]+")),
      digits + " " + digit(seed.left),
    )
    assert_done(many, digits.length() + 2)
    match many.tree {
      Some(tree) => {
        guard tree.kind == "many" else { panic() }
        guard tree.kids.length() == 2 else { panic() }
      }
      None => panic()
    }

    let opt_hit = @dslx.pars(@dslx.optx(@dslx.litx(";")), ";")
    assert_done(opt_hit, 1)
    let opt_miss = @dslx.pars(@dslx.optx(@dslx.litx(";")), "")
    assert_done(opt_miss, 0)
    match opt_miss.tree {
      Some(tree) => {
        guard tree.kind == "optx" else { panic() }
        guard tree.kids.length() == 0 else { panic() }
      }
      None => panic()
    }
  }
}

///|
test "quickcheck runx refx agrees with direct parsing" {
  let seeds : Array[PairSeed] = @quickcheck.samples(300)
  let spec = @dslx.dslx("core")
    .rule(@dslx.rule("name").body(@dslx.rgxx("[a-zA-Z_][a-zA-Z0-9_]*")))
    .rule(@dslx.rule("num").body(@dslx.rgxx("[0-9]+")))
    .rule(
      @dslx.rule("decl").body(
        @dslx.seqx([@dslx.refx("name"), @dslx.refx("num")]),
      ),
    )
  for seed in seeds {
    let ident = valid_ident(seed.left)
    let digits = digit_text(seed.right)
    let direct = @dslx.pars(
      @dslx.seqx([@dslx.rgxx("[a-zA-Z_][a-zA-Z0-9_]*"), @dslx.rgxx("[0-9]+")]),
      ident + " " + digits,
    )
    let via_ref = @dslx.runx(spec, "decl", ident + " " + digits)
    guard via_ref.done == direct.done else { panic() }
    guard via_ref.posx == direct.posx else { panic() }
    guard via_ref.digs.length() == direct.digs.length() else { panic() }
    match via_ref.tree {
      Some(tree) => {
        guard tree.kind == "seqx" else { panic() }
        guard tree.kids.length() == 2 else { panic() }
        guard tree.kids[0].kind == "refx:name" else { panic() }
        guard tree.kids[1].kind == "refx:num" else { panic() }
      }
      None => panic()
    }
  }
}

///|
test "quickcheck refx cycles never recurse forever" {
  let seeds : Array[Int] = @quickcheck.samples(120)
  let direct = @dslx.dslx("core").rule(@dslx.rule("a").body(@dslx.refx("a")))
  let indirect = @dslx.dslx("core")
    .rule(@dslx.rule("a").body(@dslx.refx("b")))
    .rule(@dslx.rule("b").body(@dslx.refx("a")))
  for seed in seeds {
    let input = valid_ident(seed)
    let one = @dslx.runx(direct, "a", input)
    guard !one.done else { panic() }
    guard one.tree is None else { panic() }
    guard one.digs.length() == 1 else { panic() }
    guard one.digs[0].text == "refx cycle" else { panic() }
    guard one.digs[0].hint == Some("a -> a") else { panic() }

    let two = @dslx.runx(indirect, "a", input)
    guard !two.done else { panic() }
    guard two.tree is None else { panic() }
    guard two.digs.length() == 1 else { panic() }
    guard two.digs[0].text == "refx cycle" else { panic() }
    guard two.digs[0].hint == Some("a -> b -> a") else { panic() }
  }
}

///|
test "quickcheck generated name validation accepts valid names and rejects invalid names" {
  let seeds : Array[Int] = @quickcheck.samples(260)
  for seed in seeds {
    let suffix = valid_ident(seed)
    let valid = @dslx.dslx("Spec" + suffix)
      .node(
        @dslx.node("Node" + suffix).case(
          @dslx.case("Case" + suffix).fldx(
            @dslx.fldx("field" + suffix, "String"),
          ),
        ),
      )
      .rule(@dslx.rule("rule" + suffix).body(@dslx.litx("x")))
    guard count_diag(@dslx.vspc(valid), "invalid generated name") == 0 else {
      panic()
    }

    let bad = invalid_name(seed)
    let invalid = @dslx.dslx(bad)
      .node(
        @dslx.node(bad).case(@dslx.case(bad).fldx(@dslx.fldx(bad, "String"))),
      )
      .rule(@dslx.rule(bad).body(@dslx.litx("x")))
    let digs = @dslx.vspc(invalid)
    if bad.length() == 0 {
      guard count_diag(digs, "empty spec name") == 1 else { panic() }
      guard count_diag(digs, "empty node name") == 1 else { panic() }
      guard count_diag(digs, "empty case name") == 1 else { panic() }
      guard count_diag(digs, "empty field name") == 1 else { panic() }
      guard count_diag(digs, "empty rule name") == 1 else { panic() }
    } else {
      guard has_diag(digs, "invalid generated name", "spec:" + bad) else {
        panic()
      }
      guard has_diag(digs, "invalid generated name", "node:" + bad) else {
        panic()
      }
      guard has_diag(digs, "invalid generated name", "case:" + bad) else {
        panic()
      }
      guard has_diag(digs, "invalid generated name", "field:" + bad) else {
        panic()
      }
      guard has_diag(digs, "invalid generated name", "rule:" + bad) else {
        panic()
      }
    }
  }
}

///|
test "quickcheck structural diagnostics remain stable for small generated specs" {
  let seeds : Array[Int] = @quickcheck.samples(180)
  for seed in seeds {
    let name = "N" + valid_ident(seed)
    let rule = "r" + valid_ident(seed / 3)
    let spec = @dslx.dslx("Spec" + valid_ident(seed / 5))
      .node(
        @dslx.node(name)
        .case(@dslx.case("Case").fldx(@dslx.fldx("field", "String")))
        .case(
          @dslx.case("Case")
          .fldx(@dslx.fldx("field", "String"))
          .fldx(@dslx.fldx("field", "String")),
        ),
      )
      .node(@dslx.node(name))
      .rule(@dslx.rule(rule).body(@dslx.seqx([])))
      .rule(@dslx.rule(rule).body(@dslx.altx([])))
      .rule(@dslx.rule("missingUse").body(@dslx.refx("missing")))
    let digs = @dslx.vspc(spec)
    guard count_diag(digs, "duplicate case name") == 1 else { panic() }
    guard count_diag(digs, "duplicate field name") == 1 else { panic() }
    guard count_diag(digs, "duplicate node name") == 1 else { panic() }
    guard count_diag(digs, "duplicate rule name") == 1 else { panic() }
    guard count_diag(digs, "empty seqx") == 1 else { panic() }
    guard count_diag(digs, "empty altx") == 1 else { panic() }
    guard count_diag(digs, "undefined refx") == 1 else { panic() }
  }
}

///|
test "quickcheck emit file order parser wrappers and escaping stay stable" {
  let seeds : Array[Int] = @quickcheck.samples(180)
  for seed in seeds {
    let suffix = valid_ident(seed)
    let first = "first" + suffix
    let second = "second" + suffix
    let out = @dslx.emit(
      @dslx.dslx("Spec" + suffix)
      .rule(@dslx.rule(first).body(@dslx.litx("a\"b\\c\n\t")))
      .rule(@dslx.rule(second).body(@dslx.refx(first))),
    )
    let mods = @dslx.mods(out)
    guard mods.length() == 4 else { panic() }
    guard mods[0].path == "astx.mbt" else { panic() }
    guard mods[1].path == "pars.mbt" else { panic() }
    guard mods[2].path == "vald.mbt" else { panic() }
    guard mods[3].path == "prnt.mbt" else { panic() }
    let pars = file_text(mods, "pars.mbt")
    let expected = "// generated pars for Spec" +
      suffix +
      "\n" +
      "fn generated_spec() -> Dslx {\n" +
      "  dslx(\"Spec" +
      suffix +
      "\").rule(rule(\"" +
      first +
      "\").body(litx(\"a\\\"b\\\\c\\n\\t\"))).rule(rule(\"" +
      second +
      "\").body(refx(\"" +
      first +
      "\")))\n" +
      "}\n" +
      "pub fn " +
      first +
      "(text : String) -> Pout { runx(generated_spec(), \"" +
      first +
      "\", text) }\n" +
      "pub fn " +
      second +
      "(text : String) -> Pout { runx(generated_spec(), \"" +
      second +
      "\", text) }\n"
    guard pars == expected else { panic() }
  }
}

///|
test "quickcheck project pack order and generated parser stay stable" {
  let seeds : Array[Int] = @quickcheck.samples(180)
  for seed in seeds {
    let suffix = valid_ident(seed)
    let rule = "main" + suffix
    let prj = @dslx.proj("Proj" + suffix)
      .file(@dslx.file("moon.pkg", "{}\n"))
      .exmp(@dslx.file("examples/" + suffix + ".dsl", "ok"))
      .dslx(
        @dslx.dslx("Spec" + suffix)
        .rule(@dslx.rule(rule).body(@dslx.refx("name")))
        .rule(@dslx.rule("name").body(@dslx.rgxx("[a-zA-Z_][a-zA-Z0-9_]*"))),
      )
    let once = @dslx.pack(prj)
    let twice = @dslx.pack(prj)
    guard once == twice else { panic() }
    guard once.length() == 6 else { panic() }
    guard once[0].path == "moon.pkg" else { panic() }
    guard once[1].path == "examples/" + suffix + ".dsl" else { panic() }
    guard once[2].path == "Spec" + suffix + "/astx.mbt" else { panic() }
    guard once[3].path == "Spec" + suffix + "/pars.mbt" else { panic() }
    guard once[3].text.contains("runx(generated_spec(), \"" + rule + "\"") else {
      panic()
    }
    guard @dslx.runx(prj.dslx[0], rule, suffix).done else { panic() }
  }
}

///|
test "quickcheck project lookup parse and examples agree with specs" {
  let seeds : Array[PairSeed] = @quickcheck.samples(180)
  for seed in seeds {
    let suffix = valid_ident(seed.left)
    let spec_name = "Spec" + suffix
    let rule = "main" + valid_ident(seed.right)
    let input = valid_ident(seed.right) + " " + digit_text(seed.left)
    let spec = @dslx.dslx(spec_name)
      .rule(@dslx.rule("name").body(@dslx.rgxx("[a-zA-Z_][a-zA-Z0-9_]*")))
      .rule(@dslx.rule("num").body(@dslx.rgxx("[0-9]+")))
      .rule(
        @dslx.rule(rule).body(
          @dslx.seqx([@dslx.refx("name"), @dslx.refx("num")]),
        ),
      )
    let file = @dslx.file("examples/" + suffix + ".dsl", input)
    let prj = @dslx.proj("Proj" + suffix)
      .exmp(file)
      .dslx(@dslx.fwds())
      .dslx(spec)
      .dslx(@dslx.wflw())
    match @dslx.fspc(prj, spec_name) {
      Some(found) => {
        guard @dslx.name(found) == spec_name else { panic() }
        guard @dslx.runp(prj, spec_name, rule, input) ==
          @dslx.runx(found, rule, input) else {
          panic()
        }
      }
      None => panic()
    }
    guard @dslx.fspc(prj, "Missing" + suffix) is None else { panic() }
    guard @dslx.chex(prj, spec_name, rule, file).length() == 0 else { panic() }
    let unknown = @dslx.runp(prj, "Missing" + suffix, rule, input)
    guard !unknown.done else { panic() }
    guard unknown.tree is None else { panic() }
    guard has_diag(unknown.digs, "unknown project spec", "Missing" + suffix) else {
      panic()
    }
    let bad = @dslx.chex(prj, spec_name, rule, @dslx.file("bad.dsl", "123"))
    guard bad.length() > 0 else { panic() }
  }
}

///|
test "quickcheck project duplicate diagnostics stay stable" {
  let seeds : Array[Int] = @quickcheck.samples(120)
  for seed in seeds {
    let suffix = valid_ident(seed)
    let spec = "Spec" + suffix
    let path = "out/" + suffix + ".mbt"
    let prj = @dslx.proj("Proj" + suffix)
      .file(@dslx.file(path, "a"))
      .exmp(@dslx.file(path, "b"))
      .dslx(@dslx.dslx(spec).rule(@dslx.rule("main").body(@dslx.litx("x"))))
      .dslx(@dslx.dslx(spec).rule(@dslx.rule("other").body(@dslx.litx("y"))))
    let digs = @dslx.vprj(prj)
    guard count_diag(digs, "duplicate spec name") == 1 else { panic() }
    guard count_diag(digs, "duplicate file path") == 5 else { panic() }
    guard has_diag(digs, "duplicate spec name", spec) else { panic() }
    guard has_diag(digs, "duplicate file path", path) else { panic() }
    guard has_diag(digs, "duplicate file path", spec + "/pars.mbt") else {
      panic()
    }
  }
}
