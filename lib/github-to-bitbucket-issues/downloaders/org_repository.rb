module GTBI
  module Downloaders
    class OrgRepository < Base
      def client_method
        "org_repos"
      end
    end
  end
end

