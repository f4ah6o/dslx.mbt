# DSLX

`dslx.mbt` is a MoonBit meta-framework for describing DSLs with one compact builder surface. It keeps public API names to four characters so coding agents can generate calls consistently.

```mbt check
///|
test {
  let spec = @dslx.dslx("sql")
    .node(
      @dslx.node("Expr").case(
        @dslx.case("Lit").fldx(@dslx.fldx("text", "String")),
      ),
    )
    .rule(
      @dslx.rule("expr").body(@dslx.altx([@dslx.tokn("name"), @dslx.litx("*")])),
    )
    .rule(
      @dslx.rule("decl").body(
        @dslx.seqx([@dslx.litx("let"), @dslx.refx("expr")]),
      ),
    )
  inspect(@dslx.name(spec), content="sql")
  inspect(@dslx.mods(@dslx.emit(spec)).length(), content="4")
  let parsed = @dslx.runx(spec, "decl", "let user")
  inspect(parsed.done, content="true")
  inspect(parsed.posx, content="8")
  match parsed.tree {
    Some(tree) => inspect(tree.kids[1].kind, content="refx:expr")
    None => inspect("none", content="tree")
  }
}
```

MoonBit uses `test` as syntax, so the test DSL entrypoint is exported as `tstx`.

`Proj` is the small project layer for grouping related specs, examples, and extra virtual files. `pack` is deterministic and only returns virtual files; it never writes to disk.

```mbt check
///|
test {
  let prj = @dslx.proj("family")
    .file(@dslx.file("README.md", "# family\n"))
    .exmp(
      @dslx.file(
        "examples/fwd.dsl", "schema User state Draft state Released entity User { id:int } rule hasEntity: custom entityCheck transition submit: Draft -> Released effect save rule hasEntity\n",
      ),
    )
    .dslx(@dslx.fwds())
    .dslx(@dslx.wflw())
  let files = @dslx.pack(prj)
  inspect(files[0].path, content="README.md")
  inspect(files[1].path, content="examples/fwd.dsl")
  inspect(files[2].path, content="Fwd/astx.mbt")
  inspect(@dslx.vprj(prj).length(), content="0")
}
```

`fspc`, `runp`, and `chex` make the project layer useful without unpacking the
`dslx` array manually. `runp` routes parsing through the named spec and rule.
`chex` checks an example file and returns parser diagnostics only when it fails.

```mbt check
///|
test {
  let file = @dslx.file(
    "examples/fwd.dsl", "schema User state Draft state Released entity User { id:int } rule hasEntity: custom entityCheck transition submit: Draft -> Released effect save rule hasEntity\n",
  )
  let prj = @dslx.proj("family").exmp(file).dslx(@dslx.fwds())
  inspect(@dslx.fspc(prj, "Fwd") is Some(_), content="true")
  inspect(@dslx.runp(prj, "Fwd", "sche", file.text).done, content="true")
  inspect(@dslx.chex(prj, "Fwd", "sche", file).length(), content="0")
  inspect(
    @dslx.runp(prj, "Missing", "sche", file.text).digs[0].text,
    content="unknown project spec",
  )
}
```

## Public API

The main objects are `Dslx`, `Spec`, `Proj`, `Node`, `Rule`, `Tree`, and `Diag`. The public traits are `Pars`, `Vald`, `Prnt`, and `Emit`.

The builder surface includes:

- core: `dslx`, `spec`, `proj`, `name`
- AST: `node`, `case`, `fldx`, `tree`, `span`
- grammar: `rule`, `body`, `seqx`, `altx`, `many`, `optx`, `litx`, `tokn`, `rgxx`, `refx`
- Pratt parser: `prat`, `pref`, `infx`, `post`, `atom`
- parser: `pars`, `runx`, `runp`
- validation and diagnostics: `vald`, `vspc`, `chec`, `warn`, `fail`, `hint`, `diag`
- printing: `prnt`, `grup`, `line`, `join`, `nest`, `brkx`
- codegen: `emit`, `file`, `mods`, `path`
- project: `pack`, `vprj`, `fspc`, `chex`, methods `dslx`, `exmp`, `file`
- examples: `fwds`, `wflw`, `domn`, `n8nx`, `rout`, `parm`, `bind`, `sqlx`, `slct`, `from`, `wher`, `ordr`, `limt`, `html`, `elem`, `attr`, `text`, `chid`, `mach`, `stat`, `tran`, `evnt`, method `init`, `tstx`, `givn`, `when`

The code generator returns virtual files only. It does not write to disk.

## Core v1 Contracts

`Pout` is the parser result. `done` is true only when parsing succeeded and all non-whitespace input was consumed, `tree` contains the parse tree on success, `posx` is the final byte offset after trailing whitespace is skipped, and `digs` contains diagnostics.

`pars(expr, text)` parses a single expression tree. It does not resolve `refx`, so named rule references should be executed through `runx(spec, rule, text)`. `pars` is strict: it skips whitespace before tokens and expressions, accepts trailing whitespace, and fails if any non-whitespace input remains after a successful expression parse. Leftover input returns `done=false`, `tree=None`, and a `fail("unexpected input")` diagnostic whose span is `span("", leftover_pos, leftover_pos)`.

`runx` looks up the start rule by name, then resolves `refx("name")` against the spec rules. It uses the same strict final-consumption rule as `pars`. Missing start rules or missing references produce `fail` diagnostics with spans. Successful `refx` parses keep a wrapper tree named `refx:<name>` around the referenced rule tree.

Generated `pars.mbt` rule functions rebuild a private generated spec and call `runx(generated_spec(), "<rule>", text)`. This means generated parser entrypoints resolve `refx` exactly like hand-written `runx` calls while still returning virtual files only.

`rgxx` intentionally supports only explicit scanner patterns in Core v1: `[0-9]+` and `[a-zA-Z_][a-zA-Z0-9_]*`. Unsupported patterns fail validation and fail parsing instead of being treated as literal prefixes.

Parse diagnostics include span information for literal, token, `rgxx`, `refx`, start-rule, and `refx` cycle failures. When there is no wider source range, the parser uses a zero-width span at the current byte offset.

Parser combinator diagnostics are conservative: `altx` discards failed earlier branches once a later branch succeeds, `many` stops on the first failed child parse without surfacing that child diagnostic, and `optx` succeeds with an empty tree when its child fails.

`vspc` validates empty names, generated-name readiness, duplicate node/case/field/rule names, undefined `refx`, unsupported `rgxx`, and empty `seqx`/`altx`. Generated-name readiness rejects spec, node, case, field, and rule names that are not MoonBit identifiers: the first byte must be an ASCII letter or `_`, later bytes must be ASCII letters, digits, or `_`, and reserved words are not accepted. Diagnostics remain `Diag` values with `kind` set to `fail` or `warn` plus short hints where useful.

`pack(proj)` keeps file order stable: explicit project files, example files, then generated files for each `Dslx` in insertion order. Generated files are namespaced as `<SpecName>/astx.mbt`, `<SpecName>/pars.mbt`, `<SpecName>/vald.mbt`, and `<SpecName>/prnt.mbt`, which lets multiple DSL specs coexist in one virtual project package. `vprj` combines spec validation with duplicate spec-name and duplicate virtual-path diagnostics.

`fspc(proj, name)` returns the matching `Dslx` by spec name. `runp(proj, spec, rule, text)` is the project-level parser entrypoint; it returns the same `Pout` as `runx` when the spec exists and returns `fail("unknown project spec")` when it does not. `chex(proj, spec, rule, file)` parses `file.text` through `runp` and returns an empty diagnostic array for successful examples.
