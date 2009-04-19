module RAM
  class Program

    attr_accessor :memory, :labels, :instructions, :row

    def self.make(mod = nil, &block)
      mod ||= Instructions
      self.new.tap { |program|
        WritingDSL.new(program, 
          mod.constants.collect {|c| [c, mod.const_get(c)]}
        ).instance_eval(&block)
      }
    end

    def initialize
      @instructions = []
      @memory = {}
      @labels = {}
      reset
    end

    def add_instruction instruction, args = []
      @instructions << [instruction, args]
    end

    def instruction_at index
      @instructions[index][0]
    end

    def reset
      @row = 0
      @halt = false
    end

    def jump label
      @row = @labels[label]
    end

    def run
      if @instructions.empty?
        raise 'Cannot run empty program, no instructions set.'
      end
      reset
      while !@halt && step; end
    rescue
      raise Magic.wrap("Problem during computation.\n\t#{memory.inspect}\n\t#{@instructions[@row].inspect}\n\t", $!)
    end

    def step
      if i = @instructions[@row]
        #p i
        @row += 1
        i[0].new(self, *i[1]).run
        true
      else
        raise "no instruction on row #{@row}, prgram should end with halt!"
      end
    end

    def halt
      @halt = true
    end

    def store at, what
      @memory[at] = what
    end

    class WritingDSL
      def initialize program, instructions
        @program = program
        instructions.each do |const|
          method_for const[0], const[1]
        end
      end

      def method_for class_name, klass
        name = name_for(class_name, klass)
        extend Module.new {
          define_method(name) do |*args|
            @program.add_instruction(klass, args)
          end
        }
      end

      def name_for class_name, klass
        if klass.respond_to? 'short_name'
           klass.short_name
        else
          class_name.gsub(/\B[A-Z]/, '_\&').downcase
        end
      end

      def label name
        @program.labels[name] = @program.instructions.length
      end

    end
  end
end