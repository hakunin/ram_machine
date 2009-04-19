require File.dirname(__FILE__)+'/machine'

require 'test/unit'

module RAM
  class ProgramTest < Test::Unit::TestCase
    def test_add_instructons
      p = Program.new
      instruction = Instructions::Halt.new(p)
      p.add_instruction instruction
      assert_equal instruction, p.instruction_at(0)
    end

    def test_program_writing_dsl
      p = Program.make() do
        halt
      end
      assert_equal Instructions::Halt, p.instruction_at(0)
    end

    module MyCrazyInstrictions
      class ReallyLongNameForAnInstriction
        def self.short_name
          'rlnfai'
        end
      end
    end

    def test_instructions_can_define_their_own_dsl_names
      p = Program.make(MyCrazyInstrictions) do
        rlnfai
      end
      assert_equal MyCrazyInstrictions::ReallyLongNameForAnInstriction, p.instruction_at(0)
    end

    def test_program_store_stores_into_memory_hash
      p = Program.make() {}
      p.store 0, 'object'
      assert_equal({0 => 'object'}, p.memory)
    end

    def test_label
      p = Program.make {
        label :here
      }
      assert_equal 0, p.labels[:here]
    end

    def test_jump_jumps_under_the_label
      p = Program.make {
        label :here
        halt
        label :here2
        halt
        label :here3
      }
      p.jump :here
      assert_equal 0, p.row
      p.jump :here2
      assert_equal 1, p.row
      p.jump :here3
      assert_equal 2, p.row
    end

    def test_running_empty_program_causes_exception
      p = Program.new
      assert_raise RuntimeError do
        p.run
      end
    end

    def test_run_program
      p = Program.make {
        load '=2'
        mul '=2'
        halt
      }
      p.run
      assert_equal 4, p.memory[0]
    end


  end
end