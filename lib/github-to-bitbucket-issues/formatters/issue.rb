module GTBI
  module Formatters
    class Issue < Base
      def formatted
        {
          :assignee => get_assignee(@raw),
          :component => get_component(@raw),
          :content => @raw.body || " ",
          :content_updated_on => @raw.updated_at,
          :created_on => @raw.updated_at,
          :edited_on => @raw.updated_at,
          :id => @raw.number,
          :kind => get_kind(@raw),
          :milestone => get_milestone(@raw),
          :priority => get_priority(@raw),
          :reporter => @raw.user.login,
          :status => get_status(@raw),
          :title => @raw.title,
          :updated_on => @raw.updated_at,
          :version => nil,
          :watchers => []
        }
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

      # Fetching the component from the labels is limited is that only one component is allowed, so we take the first label
      # Ignore labels common in GitHub that are used for other things, such as type and priority
      KNOWN_LABELS = ['enhancement','proposal','task','bug','trivial','minor','critical','blocker','major']
      def get_component(issue)
        issue.labels.map { |a| a[:name] }.reject { |a| KNOWN_LABELS.include?(a) }[0]
      end

      def get_milestone(issue)
        if issue.milestone
          milestone = issue.milestone.title
        end

        milestone
      end
    end
  end
end

