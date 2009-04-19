
module RAM
  module Instructions

    class Instruction
      attr_accessor :args, :program

      def initialize program, *args
        @program = program
        self.args = args
      end

      def run
        raise 'not implemented'
      end

      def == o
        o.class == self.class && o.args == self.args
      end
    end

    class Halt < Instruction
      def run
        program.halt
      end
    end

    class Store < Instruction
      def initialize p, variable
        super(p, [variable])
        @variable = variable
      end

      def run
        if @variable.to_s[0, 1] == '*'
          @variable = Accessor.index(program, @variable)
          puts @variable.inspect
        end        
        program.store @variable, Accessor.read(program, 0)
      end
    end

    

    class Load < Instruction
      def initialize p, variable
        super(p, [variable])
        @variable = variable
      end

      def run
        program.store 0, Accessor.read(program, @variable)
      end
    end

    class Jump < Instruction
      def initialize p, label
        @label = label
        super(p, label)
      end

      def run
        program.jump @label
      end
    end

    class JumpGraterThanZero < Jump
      def self.short_name
        'jgtz'
      end

      def run
        if program.memory[0] > 0
          super
        end
      end
    end

    class JumpZero < Jump
      def self.short_name
        'jzero'
      end

      def run
        if program.memory[0] == 0
          super
        end
      end
    end


    class Add < Instruction
      def initialize p, number
        @n = number
        super(p, number)
      end

      def run
        program.store 0, program.memory[0] + Accessor.read(program, @n)
      end
    end

    class Sub < Add
      def run
        program.store 0, program.memory[0] - Accessor.read(program, @n)
      end
    end

    class Mul < Instruction
      def initialize p, number
        @n = number
        super(p, number)
      end

      def run
        program.store 0,
          Accessor.read(program, 0) * Accessor.read(program, @n)
      end
    end


    class Div < Instruction
      def initialize p, number
        @n = number
        super(p, number)
      end

      def run
        program.store 0, program.memory[0].div(Accessor.read(program, @n))
      end
    end

    class Accessor
      def self.read(program, slot)
        if slot.to_s[0,1] == '='
          what = slot[1,:last]
          if what =~ /^[0-9]+$/
            return what.to_i
          end
        else
          what = program.memory[index(program, slot)]
        end
        what
      end

      def self.index(program, slot)
        if slot.to_s[0,1] == '*'
          var = slot[1,:last]
          unless program.memory[var]
            raise 'Theres nothing in program.memory[#{var}]. Expected to point to the beginning of the array.'
          end
          unless program.memory[1]
            raise 'No index offset specified in program.memory[1].'
          end
          at = program.memory[var] + program.memory[1]
          at
        else
          slot
        end
      end
    end

  end
end