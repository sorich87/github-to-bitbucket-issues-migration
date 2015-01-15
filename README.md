Export issues from a Github repository to the [Bitbucket
Issue Data Format](https://confluence.atlassian.com/display/BITBUCKET/Export+or+Import+Issue+Data)

## CLI Options
```
options:
 -repository     Repository username/reponame
 -username (-u)  Github login
 -password (-p)  Github password
 -filename (-o)  Output file name (default is ./export.zip) : default - export.zip
 -help (-h)      Show help
```

## Usage

```
bundle install
bundle exec ruby cli.rb --repository user/repo --username user --password *** --filename out.zip
```
