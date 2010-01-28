module Mizinco
  class Config < Hash

    def initialize(&block)
      instance_eval(&block) if block_given?
    end

    def method_missing(m, *args)
      raise ArgumentError.new("undefined method `#{m}' for #{inspect}:#{self.class}") if args.size > 1
      if m.to_s =~ /^(.+)=$/
        self[$1] = args.first
      else
        self[m.to_s]
      end
    end

    def [](key)
      super key.to_s
    end

    def []=(key, value)
      super key.to_s, value
    end

  end
end
