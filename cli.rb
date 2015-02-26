require 'rubygems'
require 'bundler/setup'
require './lib/github-to-bitbucket-issues'
require 'optparse'

options = {}
opt_parse = OptionParser.new do |opts|
  opts.banner = "Usage: 
  ruby cli.rb -u username -p password -r myrepo -o issues.zip
or
  ruby cli.rb -t token_here --organization your_org
  "
  opts.on('-t [ARG]', '--access_token [ARG]', "Github access token") do |v|
    options[:access_token] = v
  end
  opts.on('-u [ARG]', '--username [ARG]', "Github username") do |v|
    options[:username] = v
  end
  opts.on('-p [ARG]', '--password [ARG]', "Github password") do |v|
    options[:password] = v
  end
  opts.on('--organization [ARG]', "Export all organization's repositories") do |v|
    options[:organization] = v
  end
  opts.on('-o [ARG]', '--output', 'Output filename - defaults to [repo_name].zip') do |v|
    options[:filename] = v
  end
  opts.on('-r [ARG]', '--repository', 'Export only one repository') do |v|
    options[:repository] = v
    options[:filename] ||= v + '.zip'
  end
  opts.on('-h', '--help', 'Show this message') do |v|
    puts opts
    exit
  end
end
opt_parse.parse!

#
# Required parameters
#
begin
  raise OptionParser::MissingArgument unless options[:username] and options[:password] or options[:access_token]
  raise OptionParser::MissingArgument unless options[:repository] or options[:organization]
rescue OptionParser::MissingArgument
  puts "Argument Missing\n\n"
  puts opt_parse
  exit
end

GTBI::Export.new(options).generate

