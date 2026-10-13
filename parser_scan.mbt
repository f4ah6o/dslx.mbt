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
