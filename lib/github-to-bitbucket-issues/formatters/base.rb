module GTBI
  module Formatters
    class Base
      def format(item)
        {}
      end

      def accept(item, options)
        true
      end
    end
  end
end
