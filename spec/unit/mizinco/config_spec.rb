# -*- coding: utf-8 -*-
require 'mizinco/config'

describe "Mizinco::Configを使うとき" do
  before :each do
    @config = Mizinco::Config.new
  end

  it "適当な名前のアクセサを利用できること" do
    @config.hoge = "HOGE"
    @config.fuga = "FUGA"
    @config.hoge.should == 'HOGE'
    @config.fuga.should == 'FUGA'
  end

  it ".new にブロックを渡すことで値を設定できること" do
    pairs = { :key1 => :val1, :key2 => :val2, :key3 => :val3 }
    @config = Mizinco::Config.new do
      pairs.keys.each do |key|
        self.send("#{key}=", pairs[key])
      end
    end

    pairs.each do |k, v|
      @config.send(k).should == v
    end
  end

  it "[key] でアクセスできること" do
    @config.hoge = "HOGE"
    @config.fuga = "FUGA"
    @config['hoge'].should == "HOGE"
    @config['fuga'].should == "FUGA"
  end

  it "[key] でアクセスするとき、StringとSymbolを同一に扱うこと" do
    @config.hoge = "HOGE"
    @config['hoge'].object_id.should == @config[:hoge].object_id
  end
end
