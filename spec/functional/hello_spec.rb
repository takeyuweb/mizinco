# -*- coding: utf-8 -*-
require 'mizinco'

describe 'The HelloWorld Mizinco App' do
  include Rack::Test::Methods

  def app
    Mizinco::Application.new
  end

  before :all do
    @_base = Module.new
    @_base.instance_eval do
      include Mizinco::Delegator
      send :get, '' do  # '' と 'index' はおなじ
        render :html => "Hello World"
      end
      
      get 'bold' do
        render :html => "<b>Hello World</b>"
      end
    end
  end

  after :all do
    @base.instance_eval do
      reset!
    end
  end

  it "says hello" do
    get '/'
    last_response.should be_ok
    last_response.body.should == 'Hello World'
  end

  it "says hello(act=>bold)" do
    get '/', :_act => 'bold'
    last_response.should be_ok
    last_response.body.should == '<b>Hello World</b>'
  end
end

