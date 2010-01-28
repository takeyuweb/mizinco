# -*- coding: utf-8 -*-
require 'mizinco'

describe 'Filterの' do
  include Rack::Test::Methods

  def app
    Mizinco::Application.new
  end

  before :each do
    @_base = Module.new
    @_base.instance_eval do
      include Mizinco::Delegator
    end
  end

  after :each do
    @base.instance_eval do
      reset!
    end
  end

  describe 'before を使うとき' do
    it "指定したブロックが全てのアクションの前で実行されること" do
      @base.instance_eval do
        before do
          @messages ||= []
          @messages << "1st before filter"
        end
        
        get 'index' do
          render :text => @messages.join("\n")
        end
      end
      
      get '/'
      last_response.should be_ok
      last_response.body.should == '1st before filter'
    end
    
    it "定義順に実行されること" do
      @base.instance_eval do
        before do
          @messages ||= []
          @messages << "1st before filter"
        end
        
        before do
          @messages ||= []
          @messages << "2nd before filter"
        end
        
        before do
          @messages ||= []
          @messages << "3rd before filter"
        end
        
        get 'index' do
          render :text => @messages.join("\n")
        end
      end
      
      get '/'
      last_response.should be_ok
      last_response.body.should == ["1st before filter",
                                    "2nd before filter",
                                    "3rd before filter"].join("\n")
    end
    
    it "false を返した時は処理を中断すること" do
      @base.instance_eval do
        before do
          @messages ||= []
          @messages << "1st before filter"
        end
        
        before do
          @messages ||= []
          @messages << "2nd before filter"
          
          render :text => @messages.join("\n")
          false
        end
        
        before do
          @messages ||= []
          @messages << "3rd before filter"
        end
        
        get 'index' do
          render :text => 'dummy'
        end
      end
      
      get '/'
      last_response.should be_ok
      last_response.body.should == ["1st before filter",
                                    "2nd before filter"].join("\n") # 3rd は実行されない
    end
    
    it ":only で指定されたアクションでのみ実行されること" do
      @base.instance_eval do
        before do
          @messages = []
          @messages << "all"
        end
        
        before :only => :hoge do
          @messages << "hoge"
        end
        
        before :only => [:hoge, :fuga] do
          @messages << "hoge, fuga"
        end
        
        get 'index' do
          render :text => @messages.join("\n")
        end
        
        get 'hoge' do
          render :text => @messages.join("\n")
        end
        
        get 'fuga' do
          render :text => @messages.join("\n")
        end
      end
      
      get '/'
      last_response.should be_ok
      last_response.body.should == ["all"].join("\n")
      
      get '/', :_act => 'fuga'
      last_response.should be_ok
      last_response.body.should == ["all", "hoge, fuga"].join("\n")
      
      get '/', :_act => 'hoge'
      last_response.should be_ok
      last_response.body.should == ["all", "hoge", "hoge, fuga"].join("\n")
    end
    
    it ":except で指定されたアクションでは実行されないこと" do
      @base.instance_eval do
        before do
          @messages = []
          @messages << "all"
        end
        
        before :except => :hoge do
          @messages << "excluding hoge"
        end
        
        before :except => [:hoge, :fuga] do
          @messages << "excluding hoge, fuga"
        end
        
        get 'index' do
          render :text => @messages.join("\n")
        end
        
        get 'hoge' do
          render :text => @messages.join("\n")
        end
        
        get 'fuga' do
          render :text => @messages.join("\n")
        end
      end
      
      get '/'
      last_response.should be_ok
      last_response.body.should == ["all", "excluding hoge", "excluding hoge, fuga"].join("\n")
      
      get '/', :_act => 'fuga'
      last_response.should be_ok
      last_response.body.should == ["all", "excluding hoge"].join("\n")
      
      get '/', :_act => 'hoge'
      last_response.should be_ok
      last_response.body.should == ["all"].join("\n")
    end
    
  end

  describe 'after を使うとき' do
    it "指定したブロックが全てのアクションの後で実行されること" do
      @base.instance_eval do
        after do
          @messages << "1st after filter"
          
          @res = Rack::Response.new
          @res.write @messages.join("\n")
        end
        
        get 'index' do
          @messages = []
          render :text => ''
        end
      end
      
      get '/'
      last_response.should be_ok
      last_response.body.should == '1st after filter'
    end
    
    it "定義順に実行されること" do
      @base.instance_eval do
        after do
          @messages << "1st after filter"

          @res = Rack::Response.new
          @res.write @messages.join("\n")
        end
        
        after do
          @messages << "2nd after filter"

          @res = Rack::Response.new
          @res.write @messages.join("\n")
        end
        
        after do
          @messages << "3rd after filter"
                    
          @res = Rack::Response.new
          @res.write @messages.join("\n")
        end
        
        get 'index' do
          @messages = []
          render :text => ''
        end
      end
      
      get '/'
      last_response.should be_ok
      last_response.body.should == ["1st after filter",
                                    "2nd after filter",
                                    "3rd after filter"].join("\n")
    end
    
    it "false を返した時は処理を中断すること" do
      @base.instance_eval do
        after do
          @messages << "1st after filter"

          @res = Rack::Response.new
          @res.write @messages.join("\n")
        end
        
        after do          
          @messages << "2nd after filter"
          
          @res = Rack::Response.new
          @res.write @messages.join("\n")
          false
        end
        
        after do
          @messages << "3rd after filter"

          @res = Rack::Response.new
          @res.write @messages.join("\n")
        end
        
        get 'index' do
          @messages = []
          render :text => 'dummy'
        end
      end
      
      get '/'
      last_response.should be_ok
      last_response.body.should == ["1st after filter",
                                    "2nd after filter"].join("\n") # 3rd は実行されない
    end
    
    it ":only で指定されたアクションでのみ実行されること" do
      @base.instance_eval do
        after do          
          @messages << "all"
          @res = Rack::Response.new
          @res.write @messages.join("\n")
        end
        
        after :only => :hoge do
          @messages << "hoge"
          @res = Rack::Response.new
          @res.write @messages.join("\n")
        end
        
        after :only => [:hoge, :fuga] do
          @messages << "hoge, fuga"
          @res = Rack::Response.new
          @res.write @messages.join("\n")
        end
        
        get 'index' do
          @messages = []
          render :text => ''
        end
        
        get 'hoge' do
          @messages = []
          render :text => ''
        end
        
        get 'fuga' do
          @messages = []
          render :text => ''
        end
      end
      
      get '/'
      last_response.should be_ok
      last_response.body.should == ["all"].join("\n")
      
      get '/', :_act => 'fuga'
      last_response.should be_ok
      last_response.body.should == ["all", "hoge, fuga"].join("\n")
      
      get '/', :_act => 'hoge'
      last_response.should be_ok
      last_response.body.should == ["all", "hoge", "hoge, fuga"].join("\n")
    end
    
    it ":except で指定されたアクションでは実行されないこと" do
      @base.instance_eval do
        after do
          @messages << "all"
          @res = Rack::Response.new
          @res.write @messages.join("\n")
        end
        
        after :except => :hoge do
          @messages << "excluding hoge"
          @res = Rack::Response.new
          @res.write @messages.join("\n")
        end
        
        after :except => [:hoge, :fuga] do
          @messages << "excluding hoge, fuga"
          @res = Rack::Response.new
          @res.write @messages.join("\n")
        end
        
        get 'index' do
          @messages = []
          render :text => 'dummy'
        end
        
        get 'hoge' do
          @messages = []
          render :text => 'dummy'
        end
        
        get 'fuga' do
          @messages = []
          render :text => 'dummy'
        end
      end
      
      get '/'
      last_response.should be_ok
      last_response.body.should == ["all", "excluding hoge", "excluding hoge, fuga"].join("\n")
      
      get '/', :_act => 'fuga'
      last_response.should be_ok
      last_response.body.should == ["all", "excluding hoge"].join("\n")
      
      get '/', :_act => 'hoge'
      last_response.should be_ok
      last_response.body.should == ["all"].join("\n")
    end
    
  end
end
