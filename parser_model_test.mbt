///|
// The model uses character-set membership and iterators, independently of the
// scanner's integer ranges and cursor loops. Every consumed character is ASCII,
// so character counts and offsets agree even when rejected input is Unicode.
fn model_space(ch : Char) -> Bool {
  match ch {
    ' ' | '\n' | '\t' | '\r' => true
    _ => false
  }
}

///|
fn lexical_model(input : String, mode : Int) -> @dslx.Pout {
  let chars = input.to_array()
  let start = chars.iter().take_while(model_space).count()
  let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"
  let digits = "0123456789"
  let tail = letters + digits
  let width = if mode == 2 {
    chars
    .iter()
    .drop(start)
    .take_while(ch => digits.contains(ch.to_string()))
    .count()
  } else if chars.get(start) is Some(ch) && letters.contains(ch.to_string()) {
    chars
    .iter()
    .drop(start)
    .take_while(ch => tail.contains(ch.to_string()))
    .count()
  } else {
    0
  }
  let (kind, expected, hint) = match mode {
    0 => ("name", "expected token", "name")
    1 => ("rgxx", "expected pattern", "[a-zA-Z_][a-zA-Z0-9_]*")
    _ => ("rgxx", "expected pattern", "[0-9]+")
  }
  if width == 0 {
    {
      done: false,
      tree: None,
      posx: start,
      digs: [@dslx.fail(expected).span(@dslx.span("", start, start)).hint(hint)],
    }
  } else {
    let end = start + width
    let posx = end + chars.iter().drop(end).take_while(model_space).count()
    if posx == chars.length() {
      {
        done: true,
        tree: Some(
          @dslx.tree(
            kind,
            String::from_iter(chars.iter().drop(start).take(width)),
            span=@dslx.span("", start, end),
          ),
        ),
        posx,
        digs: [],
      }
    } else {
      {
        done: false,
        tree: None,
        posx,
        digs: [@dslx.fail("unexpected input").span(@dslx.span("", posx, posx))],
      }
    }
  }
}

///|
fn lexical_text(seeds : Array[Int]) -> String {
  let edges = [
    "", "0", "9", "/", ":", "@", "A", "Z", "[", "`", "a", "z", "{", "_", " ", "\n",
    "\t", "\r", "\u{b}", "\u{c}", "\u{a0}", "é", "中", "😀", "-", ";",
  ]
  seeds
  .map(seed => {
    match pidx(seed, edges.length() + 3) {
      26 => valid_ident(seed)
      27 => digit_text(seed)
      28 => name_char(seed)
      index => edges[index]
    }
  })
  .join("")
}

///|
fn lexical_agrees(input : String) -> Bool {
  let expressions = [
    @dslx.tokn("name"),
    @dslx.rgxx("[a-zA-Z_][a-zA-Z0-9_]*"),
    @dslx.rgxx("[0-9]+"),
  ]
  for mode in 0..<expressions.length() {
    if @dslx.pars(expressions[mode], input) != lexical_model(input, mode) {
      return false
    }
  }
  true
}

///|
test "core quickcheck scanners agree with independent lexical model" {
  @quickcheck.check(
    (seeds : Array[Int]) => lexical_agrees(lexical_text(seeds)),
    counterexample_context=seeds => "input=" + lexical_text(seeds).escape(),
    count=400,
    seed=20261012,
    max_size=64,
    max_shrinks=256,
  )
}

///|
test "scanner model empty invalid whitespace and character boundaries" {
  // Ensure all categories are present regardless of a random seed's distribution.
  for
    input in [
      "", " ", "\r", "\n\t", "0", "9", "/", ":", "@", "A", "Z", "[", "`", "a", "z",
      "{", "_", "_0", "a9", "0a", " a \r", " 123\t", "a b", "\u{b}", "\u{c}", "\u{a0}",
      "é", "中", "😀", "aé", "a😀", "9中",
    ] {
    assert_true(lexical_agrees(input))
  }
}

///|
fn literal_agrees(seed : (Int, Int)) -> Bool {
  let (value_seed, variant) = seed
  let value = if pidx(value_seed, 5) == 0 {
    ""
  } else {
    valid_ident(value_seed)
  }
  let prefix = match pidx(variant, 4) {
    0 => ""
    1 => "\r"
    2 => "\n\t"
    _ => " "
  }
  let suffix = match pidx(variant / 4, 4) {
    0 => value
    1 => value + " \r\n\t"
    2 => value + ";"
    _ => "!" + value
  }
  let input = prefix + suffix
  // A standard string-prefix operation is the oracle; it does not call the DSLX
  // prefix helper. Values contain no whitespace, and positions here are ASCII.
  let start = input.to_array().iter().take_while(model_space).count()
  let rest = input.view(start_offset=start).to_owned()
  let out = @dslx.pars(@dslx.litx(value), input)
  if !rest.has_prefix(value) {
    out ==
    {
      done: false,
      tree: None,
      posx: start,
      digs: [
        @dslx.fail("expected literal")
        .span(@dslx.span("", start, start))
        .hint(value),
      ],
    }
  } else {
    let end = start + value.length()
    let posx = end +
      input.to_array().iter().drop(end).take_while(model_space).count()
    if posx == input.length() {
      out ==
      {
        done: true,
        tree: Some(@dslx.tree("litx", value, span=@dslx.span("", start, end))),
        posx,
        digs: [],
      }
    } else {
      out ==
      {
        done: false,
        tree: None,
        posx,
        digs: [@dslx.fail("unexpected input").span(@dslx.span("", posx, posx))],
      }
    }
  }
}

///|
test "core quickcheck literal prefix and strict consumption model" {
  @quickcheck.check(
    literal_agrees,
    count=300,
    seed=20261013,
    max_size=64,
    max_shrinks=256,
  )
}

///|
test "literal equality empty shorter input and Unicode boundaries" {
  for value in ["", "if", "é", "中", "😀", "a中"] {
    let out = @dslx.pars(@dslx.litx(value), "\r" + value + "\r")
    assert_true(out.done)
    assert_eq(out.digs.length(), 0)
    match out.tree {
      Some(tree) => assert_eq(tree.text, value)
      None => panic()
    }
    assert_false(@dslx.pars(@dslx.litx(value), value + ";").done)
    if value != "" {
      let shorter = String::from_iter(
        value.to_array().iter().take(value.to_array().length() - 1),
      )
      assert_false(@dslx.pars(@dslx.litx(value), shorter).done)
      assert_false(@dslx.pars(@dslx.litx(value), "!").done)
    }
  }
}
