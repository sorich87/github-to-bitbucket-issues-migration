require './lib/github-to-bitbucket-issues'
require 'args_parser'

options = ArgsParser.parse ARGV do
  arg :repository, 'Repository username/reponame'
  arg :username, 'Github login', :alias => :u
  arg :password, 'Github password', :alias => :p
  arg :filename, 'Output file name (default is ./export.zip)', :alias => :o, :default => 'export.zip'
  arg :help, 'Show help', :alias => :h

  validate :repository, "Invalid repository path" do |r|
    r =~ /^[a-zA-Z0-9_\-]+\/[a-zA-Z0-9_\-]+$/
  end
end

if options.has_option? :help or !options.has_param?(:repository, :username, :password)
  STDERR.puts options.help
  exit 1
end

GTBI::Export.new(options).generate

