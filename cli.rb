require './migration'

migration = Migration.new(ARGV[0], ARGV[1])
migration.perform!
