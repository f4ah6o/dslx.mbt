///|
pub fn pars(expr : Expr, text : String) -> Pout {
  pend(pexp(expr, text, 0), text)
}

///|
pub fn runx(spec : Dslx, rule : String, text : String) -> Pout {
  match frul(spec.spec.ruls, rule) {
    Some(expr) => pend(pexs(expr, spec.spec.ruls, [rule], text, 0), text)
    None =>
      {
        done: false,
        tree: None,
        posx: 0,
        digs: [fail("unknown start rule").span(span("", 0, 0)).hint(rule)],
      }
  }
}

///|
fn pend(out : Pout, text : String) -> Pout {
  match out.tree {
    Some(_) => {
      let posx = sksp(text, out.posx)
      if posx == text.length() {
        { done: true, tree: out.tree, posx, digs: out.digs }
      } else {
        {
          done: false,
          tree: None,
          posx,
          digs: [fail("unexpected input").span(span("", posx, posx))],
        }
      }
    }
    None => { done: false, tree: None, posx: out.posx, digs: out.digs }
  }
}

///|
fn pexp(expr : Expr, text : String, posx : Int) -> Pout {
  pexs(expr, [], [], text, posx)
}

///|
fn pexs(
  expr : Expr,
  rules : Array[Rule],
  stkx : Array[String],
  text : String,
  posx : Int,
) -> Pout {
  let posx = sksp(text, posx)
  match expr {
    Litx(value) => plit(value, text, posx)
    Tokn(name) => ptok(name, text, posx)
    Rgxx(patt) => preg(patt, text, posx)
    Refx(name) =>
      if hasx(stkx, name) {
        {
          done: false,
          tree: None,
          posx,
          digs: [
            fail("refx cycle").span(span("", posx, posx)).hint(ptxt(stkx, name)),
          ],
        }
      } else {
        match frul(rules, name) {
          Some(item) => {
            let next = stkx.copy()
            next.push(name)
            let out = pexs(item, rules, next, text, posx)
            match out.tree {
              Some(node) =>
                {
                  done: true,
                  tree: Some(tree("refx:" + name, "", kids=[node])),
                  posx: out.posx,
                  digs: out.digs,
                }
              None => out
            }
          }
          None =>
            {
              done: false,
              tree: None,
              posx,
              digs: [
                fail("undefined rule").span(span("", posx, posx)).hint(name),
              ],
            }
        }
      }
    Seqx(items) => pseq(items, rules, stkx, text, posx)
    Altx(items) => palt(items, rules, stkx, text, posx)
    Many(item) => pmny(item, rules, stkx, text, posx)
    Optx(item) => {
      let out = pexs(item, rules, stkx, text, posx)
      match out.tree {
        Some(_) => out
        None =>
          { done: true, tree: Some(tree("optx", "", kids=[])), posx, digs: [] }
      }
    }
    Atom =>
      { done: true, tree: Some(tree("atom", "", kids=[])), posx, digs: [] }
  }
}

///|
fn pseq(
  items : Array[Expr],
  rules : Array[Rule],
  stkx : Array[String],
  text : String,
  posx : Int,
) -> Pout {
  let kids : Array[Tree] = []
  let digs : Array[Diag] = []
  let mut posx = posx
  for item in items {
    let out = pexs(item, rules, stkx, text, posx)
    for diag in out.digs {
      digs.push(diag)
    }
    match out.tree {
      Some(tree) => {
        kids.push(tree)
        posx = out.posx
      }
      None => return { done: false, tree: None, posx, digs }
    }
  }
  { done: true, tree: Some(tree("seqx", "", kids~)), posx, digs }
}

///|
fn palt(
  items : Array[Expr],
  rules : Array[Rule],
  stkx : Array[String],
  text : String,
  posx : Int,
) -> Pout {
  let digs : Array[Diag] = []
  for item in items {
    let out = pexs(item, rules, stkx, text, posx)
    match out.tree {
      Some(node) =>
        // Earlier failed alternatives are intentionally discarded once a later branch matches.
        return {
          done: true,
          tree: Some(tree("altx", "", kids=[node])),
          posx: out.posx,
          digs: out.digs,
        }
      None =>
        for diag in out.digs {
          digs.push(diag)
        }
    }
  }
  digs.push(fail("no alternative matched").span(span("", posx, posx)))
  { done: false, tree: None, posx, digs }
}

///|
fn pmny(
  item : Expr,
  rules : Array[Rule],
  stkx : Array[String],
  text : String,
  posx : Int,
) -> Pout {
  let kids : Array[Tree] = []
  let mut posx = posx
  let mut keep = true
  while keep {
    let out = pexs(item, rules, stkx, text, posx)
    match out.tree {
      Some(tree) =>
        if out.posx == posx {
          keep = false
        } else {
          kids.push(tree)
          posx = out.posx
        }
      None => keep = false
    }
  }
  // A failed child parse terminates zero-or-more parsing; it is not a
  // diagnostic for the caller because Many succeeds with the trees collected.
  { done: true, tree: Some(tree("many", "", kids~)), posx, digs: [] }
}

///|
fn plit(value : String, text : String, posx : Int) -> Pout {
  if pref(text, posx, value) {
    {
      done: true,
      tree: Some(
        tree("litx", value, kids=[], span=span("", posx, posx + value.length())),
      ),
      posx: posx + value.length(),
      digs: [],
    }
  } else {
    {
      done: false,
      tree: None,
      posx,
      digs: [fail("expected literal").span(span("", posx, posx)).hint(value)],
    }
  }
}

///|
fn ptok(name : String, text : String, posx : Int) -> Pout {
  let endx = scan(text, posx, true)
  if endx > posx {
    let value = text.view(start_offset=posx, end_offset=endx).to_owned()
    {
      done: true,
      tree: Some(tree(name, value, kids=[], span=span("", posx, endx))),
      posx: endx,
      digs: [],
    }
  } else {
    {
      done: false,
      tree: None,
      posx,
      digs: [fail("expected token").span(span("", posx, posx)).hint(name)],
    }
  }
}

///|
fn preg(patt : String, text : String, posx : Int) -> Pout {
  let endx = match patt {
    "[0-9]+" => scan(text, posx, false)
    "[a-zA-Z_][a-zA-Z0-9_]*" => scan(text, posx, true)
    _ =>
      return {
        done: false,
        tree: None,
        posx,
        digs: [
          fail("unsupported pattern").span(span("", posx, posx)).hint(patt),
        ],
      }
  }
  if endx > posx {
    let value = text.view(start_offset=posx, end_offset=endx).to_owned()
    {
      done: true,
      tree: Some(tree("rgxx", value, kids=[], span=span("", posx, endx))),
      posx: endx,
      digs: [],
    }
  } else {
    {
      done: false,
      tree: None,
      posx,
      digs: [fail("expected pattern").span(span("", posx, posx)).hint(patt)],
    }
  }
}

///|
fn frul(rules : Array[Rule], name : String) -> Expr? {
  for rule in rules {
    if rule.name == name {
      return Some(rule.expr)
    }
  }
  None
}

///|
fn sksp(text : String, posx : Int) -> Int {
  let mut posx = posx
  while posx < text.length() && wspc(text[posx].to_int()) {
    posx = posx + 1
  }
  posx
}

///|
fn scan(text : String, posx : Int, name : Bool) -> Int {
  let mut posx = posx
  if posx >= text.length() {
    return posx
  }
  if name {
    if !nsta(text[posx].to_int()) {
      return posx
    }
    posx = posx + 1
    while posx < text.length() && nchx(text[posx].to_int()) {
      posx = posx + 1
    }
  } else {
    while posx < text.length() && digt(text[posx].to_int()) {
      posx = posx + 1
    }
  }
  posx
}

///|
fn pref(text : String, posx : Int, pref : String) -> Bool {
  let endx = posx + pref.length()
  endx <= text.length() &&
  text.view(start_offset=posx, end_offset=endx).to_owned() == pref
}

///|
fn wspc(ch : Int) -> Bool {
  ch == 32 || ch == 10 || ch == 9 || ch == 13
}

///|
fn digt(ch : Int) -> Bool {
  ch >= 48 && ch <= 57
}

///|
fn nsta(ch : Int) -> Bool {
  (ch >= 97 && ch <= 122) || (ch >= 65 && ch <= 90) || ch == 95
}

///|
fn nchx(ch : Int) -> Bool {
  nsta(ch) || digt(ch)
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
