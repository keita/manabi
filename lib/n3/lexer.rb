require "strscan"

module N3
  class LexerError < StandardError
    def initialize(lexer)
      pos = lexer.current_position
      puts "LINE: #{pos[0]}"
      puts "COL : #{pos[1]}"
      puts "#{pos[0]}: #{pos[2]}$CUR$"
    end
  end

  class Lexer
    KEYWORDS = Regexp.union("@forAll", "@forSome", "@base", "@keywords",
                            "@prefix", ",", ".", ";", '[', ']', '{', '}',
                            "(", ")", "<=", "=>", "=")

    def initialize(str)
      @s = StringScanner.new(str)
      @pos = 0
    end

    def current_position
      lines = @s.string[0..@pos].split("\n")
      [lines.size, @pos - lines[0..-2].join.size, lines.last]
    end

    def next_token
      return nil if @s.eos?

      # skip spaces
      if size = @s.skip(/\s+|#[^\n]*|\n/)
        @pos += size
        return next_token
      end

      if m = @s.scan(KEYWORDS)
        @pos += m.size
        return [m, m]
      end

      # barename: ex. "abc", "ABC", "_abc"
      if m = @s.scan(/[A-Z_a-z][\-A-Z_a-z0-9]*(?=\s|,|\.|;|\))/)
        @pos += m.size
        return [:BARENAME, m]
      end

      # boolean
      if m = @s.scan(/@true|@false/)
        @pos += m.size
        return [:BOOLEAN, m == "@true"]
      end

      # explicituri: ex. "<#person>"
      if m = @s.scan(/<([^>]*)>/)
        @pos += m.size
        return [:EXPLICIT_URI, @s[1]]
      end

      # langcode
      if @s.matched == "@" and m = @s.scan(/[a-z]+(-[a-z0-9]+)*/)
        @pos += m.size
        return [:LANGCODE, m]
      end

      # numeric
      if m = @s.scan(/[\-+]?[0-9]+(\.[0-9]+)?([eE][\-+]?[0-9]+)?/)
        @pos += m.size
        return [:NUMERIC, m.include?(".") ? m.to_f : m.to_i]
      end

      # prefix: ex. rdf:
      if m = @s.scan(/([A-Z_a-z][\-A-Z_a-z0-9]*)?:(?=\s)/)
        @pos += m.size
        return [:PREFIX, m]
      end

      # qname: ex. ":Person", "rdf:Property"
      if m = @s.scan(/([A-Z_a-z][\-A-Z_a-z0-9]*)?:[A-Z_a-z][\-A-Z_a-z0-9]*/)
        @pos += m.size
        return [:QNAME, m]
      end

      # string: ex. "abc", """abc"""
      if (m = @s.scan(/"""((\\"|[^"])*)"""/)) or
          (m = @s.scan(/"((\\"|[^"])*)"/))
        @pos += m.size
        return [:STRING, @s[1]]
      end

      # error
      raise LexerError.new(self)
    end
  end
end
