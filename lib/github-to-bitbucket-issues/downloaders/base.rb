module GTBI
  module Downloaders
    class Base
      def initialize(client, repository, options = {})
        @client = client
        @repository = repository
        @options = options
      end

      def fetch
        items = []
        page = 1
        one_page = []

        loop do
          @options.merge!({:page => page})
          one_page = @client.send(client_method, @repository, @options)
          items += one_page
          page += 1
          break if one_page.empty?
        end

        items
      end

      protected

      def client_method
      end
    end
  end
end

