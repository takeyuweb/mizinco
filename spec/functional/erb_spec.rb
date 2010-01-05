# -*- coding: utf-8 -*-
require 'mizinco'

describe 'ERB Template Application' do
  include Rack::Test::Methods

  def app
    Mizinco::Application.new
  end

  before :all do
    @_base = Module.new
    @_base.instance_eval do
      include Mizinco::Delegator

      get 'index' do
        render # :index
      end

      get 'default' do
        render # :default
      end
      
      get 'use_action' do
        render :index
      end

      get 'set_file' do
        render 'path/set_file.erb'
      end
      
      get 'select' do
        render :action => :select, :format => params['_format']
      end

      set :template_root, File.join(File.dirname(__FILE__), 'erb_spec')
    end
  end

  after :all do
    @base.instance_eval do
      reset!
    end
  end

  it "render index.html.erb on index" do
    get '/'
    last_response.should be_ok
    last_response.body.should =~ Regexp.new(Regexp.quote("This file is index.html.erb"))
  end

  it "render default.html.erb on default" do
    get '/', :_act => 'default'
    last_response.should be_ok
    last_response.body.should =~ Regexp.new(Regexp.quote("This file is default.html.erb"))
  end

  it "render index.html.erb on use_action" do
    get '/', :_act => 'use_action'
    last_response.should be_ok
    last_response.body.should =~ Regexp.new(Regexp.quote("This file is index.html.erb"))
  end

  it "render path/set_file.erb on use_action" do
    get '/', :_act => 'set_file'
    last_response.should be_ok
    last_response.body.should =~ Regexp.new(Regexp.quote("This file is path/set_file.erb"))
  end

  it "render select.*.erb on select with html format" do
    get '/', :_act => 'select'
    last_response.body.should =~ Regexp.new(Regexp.quote("This file is select.html.erb"))

    get '/', :_act => 'select', :_format => 'xml'
    last_response.body.should =~ Regexp.new(Regexp.quote("This file is select.xml.erb"))

    get '/', :_act => 'select', :_format => 'json'
    last_response.body.should =~ Regexp.new(Regexp.quote("This file is select.json.erb"))

    get '/', :_act => 'select', :_format => 'html'
    last_response.body.should =~ Regexp.new(Regexp.quote("This file is select.html.erb"))
  end

end
