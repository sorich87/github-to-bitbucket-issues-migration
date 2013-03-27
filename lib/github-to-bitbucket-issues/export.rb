require 'octokit'
require 'zip/zip'
require 'json'

require_relative 'formatters/base'
require_relative 'formatters/issue'
require_relative 'formatters/comment'
require_relative 'formatters/milestone'
require_relative 'downloaders/base'
require_relative 'downloaders/issue'
require_relative 'downloaders/comment'
require_relative 'downloaders/milestone'

module GTBI
  class Export
    attr_reader :issues, :comments, :milestones

    def initialize(options)
      return unless options[:repository]

      @github_client = Octokit::Client.new({
        :login => options[:username],
        :password => options[:password]
      })
      @repository = options[:repository]
      @filename = options[:filename]
      @issues = []
      @comments = []
      @milestones = []
    end

    def generate
      download_issues
      download_comments
      download_milestones
      generate_archive
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

    private

    def download_issues
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
      Zip::ZipFile.open(@filename, Zip::ZipFile::CREATE) do |zipfile|
        zipfile.get_output_stream("db-1.0.json") do |f|
          f.puts to_json
        end
      end
    end
  end
end

