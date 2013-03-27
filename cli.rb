require './lib/github-to-bitbucket-issues'

if ARGV.size <= 2
  options = {
    :repository => ARGV[0],
    :filename => ARGV[1] || "export.zip"
  }
else
  options = {
    :repository => ARGV[0],
    :username => ARGV[1],
    :password => ARGV[2],
    :filename => ARGV[3] || "export.zip"
  }
end

GTBI::Export.new(options).generate

