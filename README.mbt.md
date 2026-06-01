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
  inspect(@dslx.name(spec), content="sql")
  inspect(@dslx.mods(@dslx.emit(spec)).length(), content="4")
  let parsed = @dslx.pars(
    @dslx.seqx([@dslx.litx("if"), @dslx.tokn("name")]),
    "if user",
  )
  inspect(parsed.posx, content="7")
}
```

MoonBit uses `test` as syntax, so the test DSL entrypoint is exported as `tstx`.

## Public API

The main objects are `Dslx`, `Spec`, `Node`, `Rule`, `Tree`, and `Diag`. The public traits are `Pars`, `Vald`, `Prnt`, and `Emit`.

The builder surface includes:

- core: `dslx`, `spec`, `name`
- AST: `node`, `case`, `fldx`, `tree`, `span`
- grammar: `rule`, `body`, `seqx`, `altx`, `many`, `optx`, `litx`, `tokn`, `rgxx`
- Pratt parser: `prat`, `pref`, `infx`, `post`, `atom`
- parser: `pars`
- validation and diagnostics: `vald`, `vspc`, `chec`, `warn`, `fail`, `hint`, `diag`
- printing: `prnt`, `grup`, `line`, `join`, `nest`, `brkx`
- codegen: `emit`, `file`, `mods`, `path`
- examples: `rout`, `parm`, `bind`, `sqlx`, `slct`, `from`, `wher`, `ordr`, `limt`, `html`, `elem`, `attr`, `text`, `chid`, `mach`, `stat`, `tran`, `evnt`, method `init`, `tstx`, `givn`, `when`

The code generator returns virtual files only. It does not write to disk.
