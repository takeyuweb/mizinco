$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '../../lib')

require 'mizinco'

module BBSData

  # @@datafile = File.new(File.join(File.dirname(__FILE__), 'datafile.txt'))
  # @@datafile.close
  
  #def datafile
  #  @@datafile
  #end

  #def self.path
  #  datafile.path
  #end

  def self.path
    File.join(File.dirname(__FILE__), 'datafile.txt')
  end

  def self.lines
    @@lines
  end

  def self.save!
    File.open(path, 'w') do |f|
      f.write lines.join("\n")
    end
  end
  
  def self.load
    @@lines = File.read(path).split(/\n/).collect{ |line| line.chomp }
  rescue Errno::ENOENT
    @@lines = []
  end

  load
end

get 'index' do
  @lines = BBSData.lines.reverse
end

post 'write' do
  BBSData.lines << params['line'] + "(" + Time.now.to_s + ")"
  BBSData.save!
  redirect_to :index
end

set :app_name, "1linebbs.cgi"
set :template_root, File.dirname(__FILE__)

use Rack::ShowExceptions

run!
