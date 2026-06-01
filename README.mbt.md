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
  inspect(parsed.posx, content="8")
}
```

MoonBit uses `test` as syntax, so the test DSL entrypoint is exported as `tstx`.

## Public API

The main objects are `Dslx`, `Spec`, `Node`, `Rule`, `Tree`, and `Diag`. The public traits are `Pars`, `Vald`, `Prnt`, and `Emit`.

The builder surface includes:

- core: `dslx`, `spec`, `name`
- AST: `node`, `case`, `fldx`, `tree`, `span`
- grammar: `rule`, `body`, `seqx`, `altx`, `many`, `optx`, `litx`, `tokn`, `rgxx`, `refx`
- Pratt parser: `prat`, `pref`, `infx`, `post`, `atom`
- parser: `pars`, `runx`
- validation and diagnostics: `vald`, `vspc`, `chec`, `warn`, `fail`, `hint`, `diag`
- printing: `prnt`, `grup`, `line`, `join`, `nest`, `brkx`
- codegen: `emit`, `file`, `mods`, `path`
- examples: `rout`, `parm`, `bind`, `sqlx`, `slct`, `from`, `wher`, `ordr`, `limt`, `html`, `elem`, `attr`, `text`, `chid`, `mach`, `stat`, `tran`, `evnt`, method `init`, `tstx`, `givn`, `when`

The code generator returns virtual files only. It does not write to disk.

## Core v1 Contracts

`pars(expr, text)` parses a single expression tree. It does not resolve `refx`, so named rule references should be executed through `runx(spec, rule, text)`.

`runx` looks up the start rule by name, then resolves `refx("name")` against the spec rules. Missing start rules or missing references produce `fail` diagnostics.

`rgxx` intentionally supports only explicit scanner patterns in Core v1: `[0-9]+` and `[a-zA-Z_][a-zA-Z0-9_]*`. Unsupported patterns fail validation and fail parsing instead of being treated as literal prefixes.

Parser combinator diagnostics are conservative: `altx` discards failed earlier branches once a later branch succeeds, `many` stops on the first failed child parse without surfacing that child diagnostic, and `optx` succeeds with an empty tree when its child fails.

`vspc` validates empty names, duplicate node/case/field/rule names, undefined `refx`, unsupported `rgxx`, and empty `seqx`/`altx`. Diagnostics remain `Diag` values with `kind` set to `fail` or `warn` plus short hints where useful.
