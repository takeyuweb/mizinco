# -*- coding: utf-8 -*-
require 'mizinco'

describe 'set DSL' do
  include Rack::Test::Methods

  def app
    Mizinco::Application.new
  end

  before :all do
    @_base = Module.new
    @_base.instance_eval do
      include Mizinco::Delegator

      get 'index' do
        render :html => config.app_name
      end
      
      set :app_name, "SET_SPEC"
    end
  end

  after :all do
    @base.instance_eval do
      reset!
    end
  end

  it "says app_name" do
    get '/'
    last_response.should be_ok
    last_response.body.should == "SET_SPEC"
  end

end
