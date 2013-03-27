module GTBI
  module Formatters
    class Milestone < Base
      def formatted
        {
          :name => @raw.title
        }
      end
    end
  end
end

