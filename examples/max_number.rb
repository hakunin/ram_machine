
require File.dirname(__FILE__)+'/../lib/machine'


program = RAM::Program.make do
  load 'n'
  store 1

  label :change
  load '*a'
  store :x

  label :cycle
  load 1
  sub '=1'
  jzero :end
  store 1
  load '*a'
  sub :x
  jgtz :change
  jump :cycle

  label :end
  halt
end

program.store 'n', 5
program.store 'a', 2

program.store 3, 1
program.store 4, 4
program.store 5, 8
program.store 6, 3
program.store 7, 7

program.run

p program.memory
p "biggest number is #{program.memory[:x].inspect}."
