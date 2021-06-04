{

  function ast(kind, rem) {
    const rr = {};
    Object.assign(rr, rem);
    rr.kind = kind;
    return rr;
  }

  function layers_to_interconnects(layers) {
    const interconnects = [];
    if (layers.length > 1) {
      for (let top = 1; top < layers.length; ++top) {
        interconnects.push(layers[top] * layers[top-1]);
      }
    }
    return interconnects;
  }

  function compile(items) {

    const layout_idx        = items.find(item => item.kind === 'layout'),
          node_size         = items.find(item => item.kind === 'node size')?.val         || 1,
          interconnect_size = items.find(item => item.kind === 'interconnect size')?.val || 1;

    if (layout_idx === undefined) { throw new Error('No layout specified'); }

    const layout            = layout_idx.val,
          interconnects     = layers_to_interconnects(layout),
          node_cost         = layout.reduce(        (a,c) => a+c, 0) * node_size,
          interconnect_cost = interconnects.reduce( (a,c) => a+c, 0) * interconnect_size,
          cost              = node_cost + interconnect_cost;

    const res = {
      fmt: '',
      layout,
      interconnects,
      node_size,
      interconnect_size,
      node_cost,
      interconnect_cost,
      cost
    };

    res.fmt = `${cost.toLocaleString()} bytes`;

    return res;

  }
}



Document
  = items:(_ DocumentItem)+ _ { return compile(items.map(i => i[1])); }
//  = items:DocumentItem+ _ { return items; }

DocumentItem
  = BlockComment
  / LayoutStmt
  / NodeSizeStmt
  / InterconnectSizeStmt

BlockComment
  = '/*' ch:(!'*/' .)* '*/' { return ast('block comment', { val: ch.join('') }); }

NodeSizeStmt
  = 'node size'i _ ':' _ val:Integer _ ';' { return ast('node size', { val }); }

InterconnectSizeStmt
  = 'interconnect size'i _ ':' _ val:Integer _ ';' { return ast('interconnect size', { val }); }

LayoutStmt
  = 'layout'i _ ':' _ val:LayoutSequence _ ';' { return ast('layout', { val }); }

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
