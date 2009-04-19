require File.dirname(__FILE__)+'/machine'

require 'test/unit'

module RAM

  class ProgramMock
    def initialize
      @calls = {}
    end

    def method_missing m, *args
      m = m.to_s
      @calls[m] ||= {:times => 0, :args => []}
      @calls[m][:times] += 1
      @calls[m][:args] = args
      "return value"
    end

    def called? m, expectation = 1
      m = m.to_s
      if @calls[m] == nil
        false
      else
        if @calls[m][:times] == expectation
          true
        else
          raise "#{m} was called #{@calls[m][:times]} times, but was expected to be called only #{expectation} times."
        end
      end
    end

    def args m
      m = m.to_s
      if @calls[m]
        @calls[m][:args]
      else
        nil
      end
    end
  end

  class InstructionsTest < Test::Unit::TestCase
    def setup
      @program = ProgramMock.new
    end

    def test_instruction_has_program
      assert_raise RuntimeError do
        Instructions::Instruction.new(@program).run()
      end
    end

    def test_instruction_raises_runtime_error_if_run_method_not_implemented
      assert_raise RuntimeError do
        Instructions::Instruction.new(@program).run()
      end
    end

    def test_halt_instruction_tells_program_to_stop
      Instructions::Halt.new(@program).run()
      assert @program.called?(:halt)
    end

    def test_load_instruction_sets_explicit_value
      Instructions::Load.new(@program, '=abc').run
      assert @program.called?(:store)
      assert_equal([0, 'abc'], @program.args(:store))
    end

    def test_load_instruction_sets_variable_value
      p = Program.new
      p.store 'N', 'nnn'
      Instructions::Load.new(p, 'N').run
      assert_equal 'nnn', p.memory[0]
    end

    def test_load_instruction_sets_integer_variable
      p = Program.new
      p.store 5, 5
      Instructions::Load.new(p, 5).run
      assert_equal 5, p.memory[0]
    end

    def test_load_instruction_sets_offset_value
      p = Program.new
      p.store 'a', 2
      p.store 1, 0
      p.store 2, 'aaa'
      Instructions::Load.new(p, '*a').run
      assert_equal 'aaa', p.memory[0]
    end


    def test_store_sets_value_from_working_register_to_variable
      p = Program.new
      p.store 0, 'abc'
      Instructions::Store.new(p, :N).run
      assert_equal(p.memory[:N], 'abc')
    end

    def test_store_sets_value_from_working_register_to_variable2
      p = Program.new
      p.store 0, 'abc'
      Instructions::Store.new(p, 5).run
      assert_equal(p.memory[5], 'abc')
    end

    def test_store_sets_value_according_to_offset
      p = Program.new
      p.store 0, 'working_register_value'
      offset = 1
      array_start = 5
      p.store 1, offset
      p.store 'a', array_start
      Instructions::Store.new(p, '*a').run
      memory = {
        (array_start+offset) => 'working_register_value',
        0 => 'working_register_value',
        'a' => array_start,
        1 => offset
      }
      assert_equal memory, p.memory
    end

    def test_jump
      Instructions::Jump.new(@program, 'label').run
      assert @program.called :jump
      assert_equal ['label'], @program.args(:jump)
    end

    def test_jgtz
      p = Program.make {
          halt
          label :label
      }
      p.store 0, 0
      Instructions::JumpGraterThanZero.new(p, :label).run
      assert_equal 0, p.row
      p.store 0, 1
      Instructions::JumpGraterThanZero.new(p, :label).run
      assert_equal 1, p.row
    end

    def test_jzero
      p = Program.make {
          halt
          label :label
      }
      p.store 0, 1
      Instructions::JumpZero.new(p, :label).run
      assert_equal 0, p.row
      p.store 0, 0
      Instructions::JumpZero.new(p, :label).run
      assert_equal 1, p.row
    end

    def test_add
      p = Program.make {}
      p.store 0, 5
      Instructions::Add.new(p, '=4').run
      assert_equal 9, p.memory[0]
    end

    def test_sub
      p = Program.make {}
      p.store 0, 5
      Instructions::Sub.new(p, '=4').run
      assert_equal 1, p.memory[0]
    end

    def test_multiply
      p = Program.make {}
      p.store 0, 4
      Instructions::Mul.new(p, '=3').run
      assert_equal 12, p.memory[0]
    end

    def test_div
      p = Program.make {}
      p.store 0, 4
      Instructions::Div.new(p, '=2').run
      assert_equal 2, p.memory[0]
      p.store 0, 4
      Instructions::Div.new(p, '=3').run
      assert_equal 1, p.memory[0]
    end

    def test_accessor_read
      p = Program.new
      assert_equal 123, Instructions::Accessor.read(p, '=123')
      p.store 5, 123
      assert_equal 123, Instructions::Accessor.read(p, 5)
      p.store 1, 3
      p.store 'a', 2
      p.store 5, 123
      assert_equal 123, Instructions::Accessor.read(p, '*a')
    end

  end
end