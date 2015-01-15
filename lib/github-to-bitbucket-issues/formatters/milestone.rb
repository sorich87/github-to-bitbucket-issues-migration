module GTBI
  module Formatters
    class Milestone < Base
      def format(item)
        {
          :name => item.title
        }
      end
    end
  end
end

