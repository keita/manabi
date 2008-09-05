class N3::Parser
  start document
rule
  barenames : barenames "," BARENAME { val[0] << val[2] }
            | BARENAME { return [val[0]] }

  declaration : "@base" EXPLICIT_URI { return Base.new(val[1]) }
              | "@keywords" barenames { return Keywords.new(val[1]) }
	      | "@prefix" PREFIX EXPLICIT_URI {
	           return Prefix.new(val[1], val[2])
                }

  document : statement_list

  dtlang : "@" LANGCODE
         | "^^" symbol

  existential : "@forSome" symbol_list { return Existential.new(val[1]) }

  expression : expression "!" path
  	     | expression "^" path
	     | path

  objects : objects "," expression { val[0] << val[2] }
          | expression { return [val[0]] }

  path : BOOLEAN
       | BARENAME
       | literal
       | NUMERIC
       | QUICK_VARIABLE
       | symbol
       | "(" path_list ")" { return val[1] }
       | "(" ")" { return [] }
       | "[" property_list "]" { return Something.new(val[1]) }
       | "{" statement_list "}" { return Formulae.new(val[1]) }

  path_list : path_list expression { val[0] << val[1] }
            | expression { return [val[0]] }

  property : verb objects { return Property.new(val[0], val[1]) }

  property_list : property_list ";" property { val[0] << val[2] }
  		| property { return [val[0]] }

  simple_statement : expression property_list {
                       return SimpleStatement.new(val[0], val[1])
		     }

  statement : declaration "."
            | existential "."
	    | simple_statement "."
	    | universal "."

  statement_list : statement_list statement { val[0] << val[1] }
                 | statement { return [val[0]] }

  literal : STRING dtlang
          | STRING

  symbol : EXPLICIT_URI
         | QNAME

  symbol_list : symbol_list "," symbol { val[0] << val[2] }
              | symbol { return [val[0]] }

  universal : "@forAll" symbol_list { return Universal.new(val[1]) }

  verb : expression
       | "<="
       | "="
       | "=>"
       | "@a"
       | "@has" expression
       | "@is" expression "@of"

end

---- inner

  def parse(str)
    @lexer = ::N3::Lexer.new(str)
    do_parse
  end

  def next_token
    token = @lexer.next_token
    p token if $DEBUG
    token
  end

  def on_error(error_token_id, error_value, value_stack)
    puts "Parse Error:"
    p @lexer.current_position
    puts "TOKEN: " + token_to_str(error_token_id)
    puts "VALUE: " + error_value.to_s
    p value_stack
    exit
  end
