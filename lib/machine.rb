# forward support of ruby 1.9 feature

unless Object.instance_methods.include?('tap')
  class Object
    def tap
      yield self
      self
    end
  end
end


module Magic
  def self.wrap message, exception
    ExceptionWrapper.new message, exception
  end

  class ExceptionWrapper < Exception

    attr_accessor :original_exception

    def initialize message, exception = nil
      if exception
        self.original_exception = exception
        message += "\n"+exception.message
      end
      super(message)
    end

    def backtrace
      if original_exception
        original_exception.backtrace
      else
        super()
      end
    end
  end
end


require File.dirname(__FILE__)+'/program'
require File.dirname(__FILE__)+'/instructions'

module RAM
  def self.program &block
    Program.make(&block)
  end

end