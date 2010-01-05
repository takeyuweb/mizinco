module Mizinco
  class Config
    attr_accessor :app_name, :app_root, :template_root, :script_name

    def initialize(&block)
      instance_eval(&block)
    end

  end
end
