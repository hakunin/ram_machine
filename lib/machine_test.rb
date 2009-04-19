require File.dirname(__FILE__)+'/machine'

require 'test/unit'

module RAM
  class MachineTest < Test::Unit::TestCase
    def test_write_empty_program
      program = RAM.program {}
      assert_kind_of Program, program
    end
  end
end