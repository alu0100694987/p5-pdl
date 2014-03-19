main = ()-> 
  source = original.value
  try 
    result = JSON.stringify(parse(source), null, 2)
  catch result
    result = """<div class="error">#{result}</div>"""

  OUTPUT.innerHTML = result

window.onload = ()-> 
  PARSE.onclick = main

Object.constructor::error = (message, t) ->
  t = t or this
  t.name = "SyntaxError"
  t.message = message
  throw treturn

RegExp::bexec = (str) ->
  i = @lastIndex
  m = @exec(str)
  return m  if m and m.index is i
  null

String::tokens = ->
  from = undefined # The index of the start of the token.
  i = 0 # The index of the current character.
  n = undefined # The number value.
  m = undefined # Matching
  result = [] # An array to hold the results.
  WHITES = /\s+/g
  ID = /[a-zA-Z_]\w*/g
  NUM = /\b\d+(\.\d*)?([eE][+-]?\d+)?\b/g
  STRING = /('(\\.|[^'])*'|"(\\.|[^"])*")/g
  ONELINECOMMENT = /\/\/.*/g
  MULTIPLELINECOMMENT = /\/[*](.|\n)*?[*]\//g
  ONECHAROPERATORS = /([=()&|;:,<>{}[\]])/g 
  ADDOP = /[*\/]/g
  MULTOP = /[+-]/g
  COMPARISON = /[[<>=!]=|[<>]/g # Revisar las expresiones regulares
  tokens = [
    ADDOP
    COMPARISON
    MULTIPLELINECOMMENT
    ID
    MULTOP
    NUM
    ONECHAROPERATORS
    ONELINECOMMENT
    STRING
    WHITES
  ]
  RESERVED_WORD = # Revisar
    p: "P"
    if: "IF" # Cofee la entrecomilla autom�ticamente, por ser una palabra reservada de javascript
    then: "THEN"
  
  # Make a token object.
  make = (type, value) ->
    type: type
    value: value
    from: from
    to: i

  getTok = ->
    str = m[0]
    i += str.length # Warning! side effect on i
    str

  
  # Begin tokenization. If the source string is empty, return nothing.
  return  unless this
  
  # Loop through this text
  while i < @length
    tokens.forEach (t) -> # Only ECMAScript5
      t.lastIndex = i
      return

    from = i
    
    # Ignore whitespace and comments
    if m = WHITES.bexec(this) or 
           (m = ONELINECOMMENT.bexec(this)) or 
           (m = MULTIPLELINECOMMENT.bexec(this))
      getTok()
    
    # name.
    else if m = ID.bexec(this)
      rw = RESERVED_WORD[m[0]]
      if rw
        result.push make(rw, getTok())
      else
        result.push make("ID", getTok())
    
    # number.
    else if m = NUM.bexec(this)
      n = +getTok()
      if isFinite(n)
        result.push make("NUM", n)
      else
        make("NUM", m[0]).error "Bad number"
    
    # string
    else if m = STRING.bexec(this)
      result.push make("STRING", 
                        getTok().replace(/^["']|["']$/g, ""))
    # addop
    else if m = ADDOP.bexec(this)
      result.push make("ADDOP", getTok())
      
    # multop
    else if m = MULTOP.bexec(this)
      result.push make("MULTOP", getTok())
      
    # comparison
    else if m = COMPARISON.bexec(this)
      result.push make("COMPARISON", getTok())
      
    # single-character operator
    else if m = ONECHAROPERATORS.bexec(this)
      result.push make(m[0], getTok())
    else
      throw "Syntax error near '#{@substr(i)}'"
  result

parse = (input) ->
  tokens = input.tokens()
  lookahead = tokens.shift()
  match = (t) ->
    if lookahead.type is t
      lookahead = tokens.shift()
      lookahead = null  if typeof lookahead is "undefined"
    else # Error. Throw exception
      throw "Syntax Error. Expected #{t} found '" + 
            lookahead.value + "' near '" + 
            input.substr(lookahead.from) + "'"
    return

  statements = ->
    result = [statement()]
    while lookahead and lookahead.type is ";"
      match ";"
      result.push statement()
    (if result.length is 1 then result[0] else result)

  statement = ->
    result = null
    if lookahead and lookahead.type is "ID"
      left =
        type: "ID"
        value: lookahead.value

      match "ID"
      match "="
      right = expression()
      result =
        type: "="
        left: left
        right: right
    else if lookahead and lookahead.type is "P"
      match "P"
      right = expression()
      result =
        type: "P"
        value: right
    else if lookahead and lookahead.type is "IF" # Falta el token IF
      match "IF" # Se pueden pasar argumentos sin par�ntesis, pero si no recibe ninguno, hay que ponerlo.
      left = condition() # Falta implementarlo
      match "THEN"
      right = statement()
      result =
	type: 
	left: left
	right: right
    else # Error!
      throw "Syntax Error. Expected identifier but found " + 
        (if lookahead then lookahead.value else "end of input") + 
        " near '#{input.substr(lookahead.from)}'"
    result

  condition = ->
    left = expression()
    type = lookahead.value # Se obtiene el operador de la condici�n
    match "COMPARISON"
    right = expression()
    result = # Coffee le ha colocado un return D:
      type: type
      left: left
      right: right
  
  expression = ->
    result = term()
    while lookahead and lookahead.type is "ADDOP"
      op = lookahead.value
      match "ADDOP"
      right = term()
      result =
        type: op
        left: result
        right: right
    result

  term = ->
    result = factor()
    while lookahead and lookahead.type is "MULTOP"
      op = lookahead.value
      match "MULTOP"
      right = factor()
      result =
        type: op
        left: result
        right: right
    result

  factor = ->
    result = null
    if lookahead.type is "NUM"
      result =
        type: "NUM"
        value: lookahead.value

      match "NUM"
    else if lookahead.type is "ID"
      result =
        type: "ID"
        value: lookahead.value

      match "ID"
    else if lookahead.type is "("
      match "("
      result = expression()
      match ")"
    else # Throw exception
      throw "Syntax Error. Expected number or identifier or '(' but found " + 
        (if lookahead then lookahead.value else "end of input") + 
        " near '" + input.substr(lookahead.from) + "'"
    result

  tree = statements(input)
  if lookahead?
    throw "Syntax Error parsing statements. " + 
      "Expected 'end of input' and found '" + 
      input.substr(lookahead.from) + "'"  
  tree
