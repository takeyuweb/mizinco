# -*- coding: utf-8 -*-
require 'mizinco'

describe 'リクエストメソッドによる処理の振り分けの確認：' do
  include Rack::Test::Methods

  def app
    Mizinco::Application.new
  end

  before :all do
    @_base = Module.new
    @_base.instance_eval do
      include Mizinco::Delegator
      
      send :get, 'index' do
        render :html => "GET index"
      end
      
      send :post, 'index' do
        render :html => "POST index"
      end

      send :put, 'index' do
        render :html => "PUT index"
      end

      send :delete, 'index' do
        render :html => "DELETE index"
      end
      
    end
  end

  after :all do
    @base.instance_eval do
      reset!
    end
  end

  it "GET / で get 'index' を呼び出すこと" do
    get '/'
    last_response.should be_ok
    last_response.body.should == 'GET index'
  end

  it "POST / で post 'index' を呼び出すこと" do
    post '/'
    last_response.should be_ok
    last_response.body.should == 'POST index'
  end

  it "PUT / で put 'index' を呼び出すこと" do
    put '/'
    last_response.should be_ok
    last_response.body.should == 'PUT index'
  end

  it "DELETE / で delete 'index' を呼び出すこと" do
    delete '/'
    last_response.should be_ok
    last_response.body.should == 'DELETE index'
  end

  it "GET /?_method=post で post ではなく get を呼び出すこと" do
    get '/', :_method => 'post'
    last_response.should be_ok
    last_response.body.should == 'GET index'
  end

  it "POST /?_method=get で get 'index' を呼び出すこと" do
    post '/', :_method => 'get'
    last_response.should be_ok
    last_response.body.should == 'GET index'
  end
end

