require 'yaml'
require 'octokit'
require 'httparty'

class Migration
  def initialize(github_repo, bitbucket_repo)
    @issues = []
    @history = {}
    @github_repo = github_repo
    @bitbucket_repo = bitbucket_repo

    load_history
    load_config
    setup_github
  end

  def perform!
    download_issues
    upload_issues
  end

  private

  def load_config
    config = YAML.load_file('config.yml') if File.file?('config.yml')

    @github = config['github'].each_with_object({}) {|(k,v), h| h[k.to_sym] = v}
    @bitbucket = config['bitbucket'].each_with_object({}) {|(k,v), h| h[k.to_sym] = v}
  end

  def setup_github
    @github_client = Octokit::Client.new(
      login: @github[:username],
      password: @github[:password]
    )
  end

  def load_history
    @history = YAML.load_file('history.yml') if File.file?('history.yml')

    unless @history[@github_repo]
      @history[@github_repo] = {issue: {}, comment: {}}
    end
  end

  def download_issues
    %w(open closed).each do |state|
      page = 1
      one_page = []

      loop do
        puts "Retrieving #{state} issues, page #{page}"
        one_page = @github_client.list_issues(@github_repo, {
          state: state,
          page: page,
          direction: 'asc'
        })
        @issues += one_page
        page += 1
        break if one_page.empty?
      end
    end

    puts "#{@issues.size} retrieved"
  end

  def upload_issues
    @issues.each { |issue| upload_issue(issue) }
  end

  def upload_issue(issue)
    id = get_bitbucket_id(issue.number, :issue)

    if id
      puts "Skipped issue #{issue.number}"
    else
      puts "Processing issue #{issue.number}"

      content = issue.body + "\n\nImported from Github"

      if issue.assignee && issue.assignee.login
        content += "\nAssignee: #{issue.assignee.login}"
      end

      id = open_issue(
        status: get_issue_status(issue),
        priority: get_issue_priority(issue),
        title: issue.title,
        content: content,
        kind: get_issue_kind(issue),
        milestone: get_issue_milestone(issue)
      )

      write_to_history(issue.number, id, :issue)
    end

    upload_comments(issue, id)
  end

  def get_issue_status(issue)
    if issue.state == 'closed'
      status = 'resolved'
    end

    puts "Status: #{status}"
    status
  end

  def get_issue_kind(issue)
    if issue.labels.to_s =~ /feature/i
      kind = 'proposal'
    elsif issue.labels.to_s =~ /enhancement/i
      kind = 'enhancement'
    elsif issue.labels.to_s =~ /bug/i
      kind = 'bug'
    end

    puts "Type: #{kind}"
    kind
  end

  def get_issue_priority(issue)
    if issue.labels.to_s =~ /priority/i
      priority = 'major'
    else
      priority = 'minor'
    end

    puts "Priority: #{priority}"
    priority
  end

  def get_issue_milestone(issue)
    if issue.milestone
      milestone = issue.milestone.title
    end

    puts "Milestone: #{milestone}"
    milestone
  end

  def upload_comments(issue, issue_id)
    return unless issue.comments

    comments = @github_client.issue_comments(@github_repo, issue.number)
    comments.each do |comment|
      upload_comment(comment, issue_id)
    end
  end

  def upload_comment(comment, issue_id)
    id = get_bitbucket_id(comment.id, :comment)

    puts "Skipped comment #{comment.id}" and return unless id.nil?

    puts "Processing comment #{comment.id}"

    content = comment.body + "\n\nImported from Github"

    if comment.user && comment.user.login
      content += "\nComment by: #{comment.user.login}"
    end

    id = open_comment(issue_id, {
      content: content
    })

    write_to_history(comment.id, id, :comment)
  end

  def get_bitbucket_id(github_num, type)
    @history[@github_repo][type][github_num]
  end

  def write_to_history(github_num, bitbucket_num, type)
    return unless bitbucket_num

    @history[@github_repo][type][github_num] = bitbucket_num

    File.open('history.yml', 'w') do |file|
      file.write(YAML.dump(@history))
    end
  end

  def open_issue(attributes)
    endpoint = "https://api.bitbucket.org/1.0/repositories/#{@bitbucket_repo}/issues/"

    response = HTTParty.post(endpoint, {
      body: attributes,
      basic_auth: @bitbucket
    })

    body = JSON.parse(response.body, symbolize_names: true)
    body[:local_id]
  end

  def open_comment(issue_id, attributes)
    endpoint = "https://api.bitbucket.org/1.0/repositories/#{@bitbucket_repo}/issues/#{issue_id}/comments"

    response = HTTParty.post(endpoint, {
      body: attributes,
      basic_auth: @bitbucket
    })

    body = JSON.parse(response.body, symbolize_names: true)
    body[:comment_id]
  end
end
