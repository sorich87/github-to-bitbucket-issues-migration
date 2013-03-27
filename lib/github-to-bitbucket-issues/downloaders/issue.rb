module GTBI
  module Downloaders
    class Issue < Base
      def client_method
        "list_issues"
      end
    end
  end
end

