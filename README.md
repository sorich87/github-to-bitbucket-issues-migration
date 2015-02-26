Export issues from a Github repository to the [Bitbucket
Issue Data Format](https://confluence.atlassian.com/display/BITBUCKET/Export+or+Import+Issue+Data)

## Usage

Make sure you have all dependencies:
```
bundle install
```
And then: 
```
  ruby cli.rb -u username -p password -r myrepo -o issues.zip
  or
  ruby cli.rb -t token_here --organization your_org

    -t, --access_token [ARG]         Github access token
    -u, --username [ARG]             Github username
    -p, --password [ARG]             Github password
        --organization [ARG]         Export all organization's repositories
    -o, --output [ARG]               Output filename - defaults to [repo_name].zip
    -r, --repository [ARG]           Export only one repository
    -h, --help                       Show this message
```
