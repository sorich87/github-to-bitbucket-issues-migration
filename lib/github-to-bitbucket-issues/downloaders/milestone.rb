module GTBI
  module Downloaders
    class Milestone < Base
      def client_method
        "list_milestones"
      end
    end
  end
end

