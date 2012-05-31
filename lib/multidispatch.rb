class Multidispatch
  def initialize(object)
    @object = object
    @methods = {}
  end
  
  def define(method_name, *args, &block)
    @methods[method_name] ||= []
    @methods[method_name] << [args, block]
    
    unless @object.methods.include?(method_name)
      (class << @object; self; end).send(:define_method, method_name) do |*args|
        @dispatcher.call(method_name, *args)
      end
    end
  end
  
  def call(method_name, *args)
    @methods[method_name].each do |defined_args, block|
      if match?(defined_args, args)
        return block.call(*args)
      end
    end
    
    raise "Could not find a method to dispatch to."
  end
  
  def match?(defined_args, args)
    defined_args.zip(args).all? do |defined_arg, arg|
      if defined_arg.is_a?(Class)
        arg.is_a?(defined_arg)
      else
        arg == defined_arg
      end
    end
  end
end

class Object
  def dispatch(method_name, *args, &block)
    @dispatcher ||= Multidispatch.new(self)
    @dispatcher.define(method_name, *args, &block)
  end
end


dispatch(:fib, 0) { 1 }
dispatch(:fib, 1) { 1 }
dispatch(:fib, Integer) { |n| fib(n-1) + fib(n-1) }

puts fib(1)
puts fib(3)
puts fib(5)