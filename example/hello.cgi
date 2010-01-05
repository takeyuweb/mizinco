#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '../lib')

require 'mizinco'

get 'index' do
  render :text => "#{config.app_name}: Hello, \"Mizinco\" World!!"
end

get 'bold' do
  render :html => "#{config.app_name}: <b>Hello, \"Mizinco\" World!!</b>"
end

set :app_name, "hello.cgi"

use Rack::ShowExceptions

run!
