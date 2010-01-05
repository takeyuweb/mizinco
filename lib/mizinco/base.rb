# -*- coding: utf-8 -*-

begin
  require 'rack'
rescue LoadError
  require 'rubygems'
  require 'rack'
end
require 'rackrequestfix'
require 'erb'
require 'uri'

require 'mizinco/config'
require 'mizinco/helper'

require 'benchmark'
class Rack::Benchmark
  def initialize(app)
    @app = app
  end

  def call(env)
    status = headers = body = nil
    t = Benchmark.realtime do
      status, headers, body = @app.call(env)
    end
    headers['X-Runtime'] = t.to_s
    [status, headers, body]
  end
end

# 設定Configのデフォルト値の変更
# class MyApp < Mizinco::Base
#   def self.default_config_options
#     super.merge(:app_name => 'NewDefault')
#   end
# end

module Mizinco
  class Base

    class << self

      def default_config_options
        {
          :app_name => 'Nameless',
          :app_root => '.',
          :template_root => './views'
        }
      end
      private :default_config_options

      def reset!
        @helpers = []
        @middleware = []
        @proc_list = { 
          :get => { },
          :post => { },
          :put => { },
          :delete => { }
        }
        @config = nil
      end

      def inherited(subclass)
        subclass.reset!
        super
      end
      
      def get(act, &block)
        act = 'index' if act.to_s.empty?
        @proc_list[:get][act.to_sym] = block
      end

      def post(act, &block)
        act = 'index' if act.to_s.empty?
        @proc_list[:post][act.to_sym] = block
      end

      def put(act, &block)
        act = 'index' if act.to_s.empty?
        @proc_list[:put][act.to_sym] = block
      end

      def delete(act, &block)
        act = 'index' if act.to_s.empty?
        @proc_list[:delete][act.to_sym] = block
      end
      
      def proc_list
        if superclass.respond_to?(:proc_list)
          ret = { }
          superclass.proc_list.each do |k, v|
            ret[k] = v.merge(@proc_list[k])
          end
          ret
        else
          @proc_list
        end
      end
      
      def helper(*args)
        args.each{ |arg| helpers << arg }
      end
      
      def helpers
        if superclass.respond_to?(:heplers)
          superclass.helpers + @helpers
        else
          @helpers
        end
      end

      def middleware
        if superclass.respond_to?(:middleware)
          superclass.middleware + @middleware
        else
          @middleware
        end
      end

      def use(klass, *args, &block)
        @middleware << [klass, args, block]
      end

      def run!
        Rack::Handler::CGI.run self.new
      end

      def config
        config_options = default_config_options
        @config ||= Mizinco::Config.new do
          config_options.each do |k, v|
            self.send("#{k}=", v)
          end
        end
      end

      def set(key, value)
        config.send("#{key}=", value)
      end

      alias :_new :new
      def new(*args, &block)
        builder = Rack::Builder.new
        builder.use Rack::Benchmark
        middleware.each { |c,a,b| builder.use(c, *a, &b) }
        builder.run super
        builder.to_app
      end

    end

    reset!

    attr_reader :res, :req

    def initialize(&block)
      block.call config if block_given?
    end

    def call(env)
      @res = Rack::Response.new
      @req = Rack::Request.new(env)
      act = @req['_act'] || 'index'
      execute(act)
      @res.finish
    end

    private
    # HTTP Request Method :get/:post/:put/:get
    # ただし、POST時に_methodパラメータが指定されているときは
    # そのメソッドとする
    def request_method
      return @request_method if @request_metho
      param_method = params['_method'].to_s.upcase
      method_name = req.request_method == 'POST' &&
        %w(GET PUT DELETE).include?(param_method) ? param_method : req.request_method
      @request_method = method_name.downcase.to_sym
    end

    def uri
      @uri ||= URI(req.url)
    end

    def params
      req.params
    end

    def cookies
      req.cookies
    end

    def config
      self.class.config
    end

    def execute(act)
      @act = act.to_sym
      proc = self.class.proc_list[request_method][@act]
      raise RuntimeError, "#{request_method.to_s.upcase} #{@act} is not defined." unless proc
      ret = instance_eval(&proc)
      render if @res.empty?
      
      ! @res.empty?
    end

    def compute_template_path(name, format)
      File.join(config.template_root, "#{name}.#{format}.erb")
    end

    # render # => <act>.html.erb
    # render :hoge # => hoge.html.erb
    # render 'path/hoge.erb' # => path/hoge.erb
    # render :patial => 'parts' # => _parts.html.erb
    # render :hoge, :format => 'xml' # => hoge.xml.erb
    # render :text => '<b>hoge</b>' # => "&lt;b&gt;hoge&lt;/b&gt;"
    # render :html => '<b>hoge</b>' # => "<b>hoge</b>"
    # render :inline => '<%= "Hello" %>' # => "Hello"
    def render(options = nil, scope = Object.new)
      options ||= @act
      format = nil
      template_path = nil
      case options
      when Hash
        format = options[:format].to_s.empty? ? 'html' : options[:format]
        if options[:partial]
          template_path = compute_template_path("_#{options[:partial]}", format)
          template_source = ERB.new(File.read(template_path), nil, '-', '@_out_buf').src
        elsif options[:action]
          template_path = compute_template_path(options[:action], format)
          template_source = ERB.new(File.read(template_path),
                                  nil, '-', '@_out_buf').src
        elsif options[:file]
          template_path = File.join(config.template_root, options[:file])
          template_source = ERB.new(File.read(options), nil, '-', '@_out_buf').src
        elsif options[:text]
          output = ERB::Util.h(options[:text])
        elsif options[:html]
          output = options[:html]
        elsif options[:inline]
          template_path = "#{request_method} #{@act}"
          template_source = ERB.new(options[:inline].to_s, nil, '-', '@_out_buf').src
        end
      when Symbol
        format = 'html'
        template_path = compute_template_path(options, 'html')
        template_source = ERB.new(File.read(template_path), nil, '-', '@_out_buf').src
      when String
        format = 'html'
        template_path = File.join(config.template_root, options)
        template_source = ERB.new(File.read(template_path), nil, '-', '@_out_buf').src
      end
      
      unless output
        # ヘルパの準備
        ([Mizinco::Helper, ERB::Util] | self.class.helpers).each{ |helper| scope.extend helper }
        # インスタンス変数のコピー
        scope.instance_variable_set('@app', self)
        instance_variables.collect do |var|
          scope.instance_variable_set(var, instance_variable_get(var))
        end
        
        # スクリプト実行
        original_out_buf =
          scope.instance_variables.any? { |var| var.to_sym == :@_out_buf } &&
          scope.instance_variable_get(:@_out_buf)
        scope.instance_eval template_source, template_path, 0
        output = scope.instance_variable_get(:@_out_buf)
        scope.instance_variable_set(:@_out_buf, original_out_buf)
      end
      
      res.write output unless options.is_a?(Hash) && !options[:partial].to_s.empty?

      output
    end

    def redirect_to(target, options = { })
      res.status = options[:permanent] ? 301 : 302
      location = case target
                 when String
                   target
                 when Symbol
                   url_for target
                 end
      res['Location'] = location
      res.write "Redirect to: #{ location }(<a href=\"#{ location }\">here</a>)"
      
      location
    end

    def url_for(act)
      path = config.script_name || uri.path
      if act.to_s == 'index'
        path
      else
        "#{ path }?_act=#{act}"
      end
    end

  end
end

module Mizinco
  class Application < Base
  end
end
