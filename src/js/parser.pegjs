
Result
  = d:Description {
    const interconnects = [];
    if (d.length > 1) {
      for (let top = 1; top < d.length; ++top) {
        interconnects.push(d[top] * d[top-1]);
      }
    }
    return { layers: d, interconnects };
  }

Description
  = e:Expression _ (","/";"/"|") _ d:Description { return [].concat(e,d); }
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
  = [ \t\n\r\v]* { return { kind: 'ws' } }
