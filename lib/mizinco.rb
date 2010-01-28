require 'mizinco/base'

module Mizinco
  module Delegator

    def self.delegate(klass, *methods)
      methods.each do |method_name|
        module_eval <<-RUBY, '(__DELEGATE__)', 1
          def #{method_name}(*args, &block)
            ::#{klass.name}.send(#{method_name.inspect}, *args, &block)
          end
          private #{method_name.inspect}
        RUBY
      end
    end
    
  end
end

Mizinco::Delegator.delegate Mizinco::Application, :get, :post, :put, :delete, :set, :run!, :helper, :use, :reset!, :before, :after, :around

include Mizinco::Delegator

