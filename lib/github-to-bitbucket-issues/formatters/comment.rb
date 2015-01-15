module GTBI
  module Formatters
    class Comment < Base
      def format(item)
        {
          :content => item.body,
          :created_on => item.created_at,
          :id => item.id,
          :issue => get_issue(item),
          :updated_on => item.updated_at,
          :user => item.user.login
        }
      end

      private

      def get_issue(comment)
        comment.issue_url.split('/').last
      end

    end
  end
end

