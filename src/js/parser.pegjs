{

  function ast(kind, rem) {
    const rr = {};
    Object.assign(rr, rem);
    rr.kind = kind;
    return rr;
  }

}



Document
  = items:DocumentItem+ _ { return items; }

DocumentItem
  = LayoutStmt
  / NodeSizeStmt
  / InterconnectSizeStmt

NodeSizeStmt
  = _ 'node size'i _ ':' _ val:Integer _ ';' { return ast('node size', { val }); }

InterconnectSizeStmt
  = _ 'interconnect size'i _ ':' _ val:Integer _ ';' { return ast('interconnect size', { val }); }

LayoutStmt
  = _ 'layout'i _ ':' _ val:LayoutSequence _ ';' { return ast('layout', { val }); }

LayoutSequence
  = e:Expression _ (","/"|") _ l:LayoutSequence { return [].concat(e,l); }
  / Expression

Expression
  = head:Term tail:(_ ("+" / "-") _ Term)* {
      return tail.reduce(function(result, element) {
        if (element[1] === "+") { return result + element[3]; }
        if (element[1] === "-") { return result - element[3]; }
      }, head);
    }

Term
  = head:Factor tail:(_ ("*" / "/") _ Factor)* {
      return tail.reduce(function(result, element) {
        if (element[1] === "*") { return result * element[3]; }
        if (element[1] === "/") { return result / element[3]; }
      }, head);
    }

Factor
  = "(" _ expr:Expression _ ")" { return expr; }
  / Integer

Integer "integer"
  = _ [0-9]+ { return parseInt(text(), 10); }

_ "whitespace"
  = val:[ \r\n\t\v]* { return ast('whitespace', val); }
