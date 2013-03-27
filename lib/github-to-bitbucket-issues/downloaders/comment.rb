module GTBI
  module Downloaders
    class Comment < Base
      def client_method
        "issues_comments"
      end
    end
  end
end

