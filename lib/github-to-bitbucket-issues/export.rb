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
      @skip_pull_requests = options.has_option? :prskip
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
      @issues = download_all_of(
          "issue",
          {:state => "all"},
          {:skip_pull_requests => @skip_pull_requests}
      )
    end

    def download_comments
      @comments = download_all_of("comment")
    end

    def download_milestones
      @milestones = download_all_of("milestone")
    end

    def download_all_of(type, download_options = {}, accept_options = {})
      items = downloader(type).new(@github_client, @repository, download_options).fetch
      formatter = formatter(type).new
      items = items.select { |item| formatter.accept(item, accept_options) }
      items.map { |item| formatter.format(item) }
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

