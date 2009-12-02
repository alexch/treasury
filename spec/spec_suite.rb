require 'rubygems'
require 'rake'

Dir.chdir(File.dirname(__FILE__)+"/../") do
 Dir["spec/**/*_spec.rb"].each do |f|
   require f
 end
end