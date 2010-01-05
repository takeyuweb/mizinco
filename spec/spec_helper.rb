require 'pp'

[ STDOUT, STDERR ].each {  |io| io.sync = true }

begin
  require 'rack/test'
rescue LoadError
  require 'rubygems'
  require 'rack/test'
end
begin
  require 'rack/mock'
rescue LoadError
  require 'rubygems'
  require 'rack/test'
end

$LOAD_PATH.unshift File.dirname(File.dirname(__FILE__)) + '/lib'
