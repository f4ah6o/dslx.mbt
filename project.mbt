///|
pub fn Proj::dslx(self : Proj, item : Dslx) -> Proj {
  let dslx = self.dslx.copy()
  dslx.push(item)
  { name: self.name, dslx, exmp: self.exmp, mods: self.mods }
}

///|
pub fn Proj::exmp(self : Proj, item : File) -> Proj {
  let exmp = self.exmp.copy()
  exmp.push(item)
  { name: self.name, dslx: self.dslx, exmp, mods: self.mods }
}

///|
pub fn Proj::file(self : Proj, item : File) -> Proj {
  let mods = self.mods.copy()
  mods.push(item)
  { name: self.name, dslx: self.dslx, exmp: self.exmp, mods }
}

///|
pub fn fspc(value : Proj, name : String) -> Dslx? {
  for item in value.dslx {
    if item.spec.name == name {
      return Some(item)
    }
  }
  None
}

///|
pub fn runp(value : Proj, spec : String, rule : String, text : String) -> Pout {
  match fspc(value, spec) {
    Some(item) => runx(item, rule, text)
    None =>
      {
        done: false,
        tree: None,
        posx: 0,
        digs: [fail("unknown project spec").span(span("", 0, 0)).hint(spec)],
      }
  }
}

///|
pub fn chex(
  value : Proj,
  spec : String,
  rule : String,
  file : File,
) -> Array[Diag] {
  let out = runp(value, spec, rule, file.text)
  if out.done {
    []
  } else {
    out.digs
  }
}

///|
pub fn pack(value : Proj) -> Array[File] {
  let out : Array[File] = []
  for item in value.mods {
    out.push(item)
  }
  for item in value.exmp {
    out.push(item)
  }
  for item in value.dslx {
    let emix = item.emit()
    for mod in emix.mods {
      out.push(file(item.spec.name + "/" + mod.path, mod.text))
    }
  }
  out
}

///|
pub fn vprj(value : Proj) -> Array[Diag] {
  let digs : Array[Diag] = []
  if value.name.length() == 0 {
    digs.push(fail("empty project name"))
  }
  let spec : Array[String] = []
  for item in value.dslx {
    if hasx(spec, item.spec.name) {
      digs.push(fail("duplicate spec name").hint(item.spec.name))
    }
    spec.push(item.spec.name)
    for diag in vspc(item) {
      digs.push(diag)
    }
  }
  let path : Array[String] = []
  for item in pack(value) {
    if hasx(path, item.path) {
      digs.push(fail("duplicate file path").hint(item.path))
    }
    path.push(item.path)
  }
  digs
}
