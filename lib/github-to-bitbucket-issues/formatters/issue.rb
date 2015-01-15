module GTBI
  module Formatters
    class Issue < Base
      def format(item)
        {
          :assignee => get_assignee(item),
          :component => nil,
          :content => item.body || " ",
          :content_updated_on => item.updated_at,
          :created_on => item.updated_at,
          :edited_on => item.updated_at,
          :id => item.number,
          :kind => get_kind(item),
          :milestone => get_milestone(item),
          :priority => get_priority(item),
          :reporter => item.user.login,
          :status => get_status(item),
          :title => item.title,
          :updated_on => item.updated_at,
          :version => nil,
          :watchers => []
        }
      end

      def accept(issue, options)
        !options[:skip_pull_requests] || issue.pull_request.nil? || issue.pull_request.patch_url.nil?
      end

      private

      def get_assignee(issue)
        issue.assignee.login if issue.assignee && issue.assignee.login
      end

      def get_status(issue)
        if issue.state == 'closed'
          'resolved'
        else
          'new'
        end
      end

      def get_kind(issue)
        if issue.labels.to_s =~ /enhancement/i
          'enhancement'
        elsif issue.labels.to_s =~ /proposal/i
          'proposal'
        elsif issue.labels.to_s =~ /task/i
          'task'
        else
          'bug'
        end
      end

      def get_priority(issue)
        if issue.labels.to_s =~ /trivial/i
          'trivial'
        elsif issue.labels.to_s =~ /minor/i
          'minor'
        elsif issue.labels.to_s =~ /critical/i
          'critical'
        elsif issue.labels.to_s =~ /blocker/i
          'blocker'
        else
          'major'
        end
      end

      def get_milestone(issue)
        if issue.milestone
          issue.milestone.title
        else
          nil
        end
      end
    end
  end
end

