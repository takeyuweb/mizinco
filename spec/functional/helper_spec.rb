# -*- coding: utf-8 -*-
require 'mizinco'

describe 'ヘルパを利用するとき' do
  include Rack::Test::Methods

  def app
    Mizinco::Application.new
  end

  before :all do
    @_base = Module.new
    @_base.instance_eval do
      include Mizinco::Delegator
      
      module MyHelperA
        def a(str)
          "a:#{str}"
        end
      end

      module MyHelperB
        def b(str)
          "b:#{str}"
        end
      end

      get 'index' do
        render :inline => "<%=a 'Hello'%> <%=b 'World'%>"
      end
      
      helper MyHelperA, MyHelperB
    end
  end

  after :all do
    @base.instance_eval do
      reset!
    end
  end

  it "MyHelperA#a 及び MyHelperB#b がビューで使えること" do
    get '/'
    last_response.should be_ok
    last_response.body.should == "a:Hello b:World"
  end

end
