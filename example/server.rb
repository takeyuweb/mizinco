# -*- coding: utf-8 -*-

# CGIテスト用サーバ
# ruby server.rb -p 3000

require "optparse"
require 'thread'
require 'pathname'
require 'webrick'
require 'webrick/cgi'
include WEBrick

opts = OptionParser.new
opts.on('-p')
opts.parse!(ARGV)

port = ARGV[0] ? ARGV[0] : 10080

rootpath = Pathname.new(File.dirname(__FILE__)).realpath
puts 'booting...'
server = HTTPServer.new({
                          :BindAddress => '0.0.0.0',
                          :Port => port,
                          :DocumentRoot => rootpath.to_s,
                          :CGIInterpreter => '/usr/bin/ruby',
                        })

puts 'trap'
['INT', 'TERM'].each do |signal|
  Signal.trap(signal){ server.shutdown }
end

mounted_names = []

puts 'loading...'
%w(perl ruby).each do |type|
  Dir.glob(File.join(rootpath.to_s, "#{type}/**/*.cgi")) do |name|
    puts name
    next if mounted_names.include?(name)
    cginame = File.join('/',  Pathname.new(name).relative_path_from(rootpath).to_s)
    server.mount(cginame, WEBrick::HTTPServlet::CGIHandler, name)
    puts "mount: #{cginame}"
    mounted_names << name
  end
end

puts 'mounted.'

server.start

