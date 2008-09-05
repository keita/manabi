module N3
  VERSION = 0

  class Document
    attr_reader :statements

    def initialize(statements)
      @statements = statements
    end
  end

  class Base
    attr_reader :uri

    def initialize(uri)
      @uri = uri
    end

    def inspect
      "#<#{self.class} URI:#{@uri}>"
    end

    alias_method :to_s, :inspect
  end

  class Prefix
    attr_reader :name
    attr_reader :uri

    def initialize(name, uri)
      @name = name
      @uri = uri
    end

    def inspect
      "#<N3::Prefix #{@name} => #{@uri}>"
    end

    alias_method :to_s, :inspect
  end

  class Keywords
    attr_reader :names

    def initialize(names)
      @names = names
    end

    def inspect
      "#<#{self.class} NAME=[#{@names.join(", ")}]>"
    end

    alias_method :to_s, :inspect
  end

  class Property
    attr_reader :predicate
    attr_reader :objects

    def initialize(symbol, objects)
      @predicate = symbol
      @objects = objects
    end

    def inspect
      objects = @objects.map{|o| o.inspect}.join(", ")
      "#<#{self.class} PRED:#{@predicate} OBJ:[#{objects}]>"
    end

    alias_method :to_s, :inspect
  end

  class Something
    attr_reader :properties

    def initialize(properties)
      @properties = properties
    end

    def inspect
      "#<#{self.class} PROP:[#{@properties.join(", ")}]>"
    end

    alias_method :to_s, :inspect
  end

  class Formulae
    attr_reader :statements

    def initialize(statements)
      @statements = statements
    end

    def inspect
      s = @statements.map{|o| o.inspect}.join(", ")
      "#<#{self.class} S:[#{s}]>"
    end

    alias_method :to_s, :inspect
  end

  class SimpleStatement
    attr_reader :subject
    attr_reader :properties

    def initialize(subject, properties)
      @subject = subject
      @properties = properties
    end

    def inspect
      "#<#{self.class} SUBJ:#{@subject} PROP:[#{@properties.join(", ")}]>"
    end

    alias_method :to_s, :inspect
  end

  class Quantifier
    attr_reader :symbols

    def initialize(symbols)
      @symbols = symbols
    end

    def inspect
      "#<#{self.class} SYM:[#{@symbols.join(", ")}]>"
    end

    alias_method :to_s, :inspect
  end

  class Universal < Quantifier; end
  class Existential < Quantifier; end
end

require "n3/lexer"
require "n3/parser"

if __FILE__ == $0
  require "pp"
  pp N3::Parser.new.parse(ARGF.read)
end
