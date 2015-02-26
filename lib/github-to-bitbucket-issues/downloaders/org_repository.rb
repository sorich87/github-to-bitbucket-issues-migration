module GTBI
  module Downloaders
    class Orgrepository < Base
      def client_method
        "org_repos"
      end
    end
  end
end

