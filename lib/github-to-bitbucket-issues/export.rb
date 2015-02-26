require 'octokit'
require 'zip'
require 'json'

require_relative 'formatters/base'
require_relative 'formatters/issue'
require_relative 'formatters/comment'
require_relative 'formatters/milestone'
require_relative 'downloaders/base'
require_relative 'downloaders/issue'
require_relative 'downloaders/comment'
require_relative 'downloaders/org_repository'
require_relative 'downloaders/milestone'

module GTBI
  class Export
    attr_reader :issues, :comments, :milestones

    def initialize(options)
      return if not options[:repository] and not options[:organization]

      @github_client = Octokit::Client.new({
        :login => options[:username],
        :password => options[:password],
        :access_token => options[:access_token]
      })
      @repository = options[:repository]
      @filename = options[:filename]
      @organization = options[:organization]
      @issues = []
      @comments = []
      @milestones = []
    end

    def generate
      repos = if @organization then download_organization_repos else [@repository] end
      repos.each do |repo|
        puts "Fetch #{repo}"
        @repository = repo
        @filename = repo.gsub('/','_') + '.zip'
        download_issues
        download_comments
        download_milestones
        generate_archive
      end
    end

    def to_json
      JSON.pretty_generate({
        :issues => @issues,
        :comments => @comments,
        :milestones => @milestones,
        :attachments => [],
        :logs => [],
        :meta => {
          :default_assignee => nil,
          :default_component => nil,
          :default_kind => "bug",
          :default_milestone => nil,
          :default_version => nil
        },
        :components => [],
        :versions => []
      })
    end

    def download_organization_repos
      repos = downloader("orgrepository").new(@github_client, @organization, {}).fetch
      repos.map do |item|
        "#{@organization}/#{item.name}"
      end
    end

    private

    def download_issues
      @issues = []
      %w(open closed).each do |state|
        @issues += download_all_of("issue", {:state => state})
      end
    end

    def download_comments
      @comments = download_all_of("comment")
    end

    def download_milestones
      @milestones = download_all_of("milestone")
    end

    def download_all_of(type, options = {})
      items = downloader(type).new(@github_client, @repository, options).fetch
      items.map do |item|
        formatter(type).new(item).formatted
      end
    end

    def downloader(type)
      Object.const_get("GTBI").const_get("Downloaders").const_get(type.capitalize)
    end

    def formatter(type)
      Object.const_get("GTBI").const_get("Formatters").const_get(type.capitalize)
    end

    def generate_archive
      Zip::File.open(@filename, Zip::File::CREATE) do |zipfile|
        zipfile.get_output_stream("db-1.0.json") do |f|
          f.puts to_json
        end
      end
    end
  end
end

