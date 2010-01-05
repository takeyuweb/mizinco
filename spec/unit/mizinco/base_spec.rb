# -*- coding: utf-8 -*-
require 'mizinco/base'

describe 'Mizinco::Base#redirect_to を使うとき' do

  before :all do
    @app = Mizinco::Base._new
    @app.instance_eval do
      @req = Rack::Request.new(Rack::MockRequest.env_for('/'))
      @res = Rack::Response.new
    end
    @req = @app.req
    @res = @app.res
  end

  after :all do
    Mizinco::Base.reset!
  end

  it "Symbolを与えたときはそのアクションへのリダイレクトになること" do
    @app.send(:redirect_to, :test)
    @res.status.should == 302
    @res['Location'].should == '/?_act=test'
  end

  it "オプションで301リダイレクトが可能なこと" do
    @app.send(:redirect_to, :test, :permanent => true)
    @res.status.should == 301
    @res['Location'].should == '/?_act=test'
  end

  it "Stringを与えたときはそのURLへのリダイレクトになること" do
    @app.send(:redirect_to, 'http://www.yahoo.co.jp/')
    @res.status.should == 302
    @res['Location'].should == 'http://www.yahoo.co.jp/'
  end

  it "script_name の設定でアクションへのリダイレクトの際のURLを指定できること" do
    Mizinco::Base.config.script_name = '/hoge.cgi'
    @app.send(:redirect_to, :test)
    @res.status.should == 302
    @res['Location'].should == '/hoge.cgi?_act=test'
  end

end

