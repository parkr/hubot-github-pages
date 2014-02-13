# hubot-github-pages

Let hubot fetch info about the GitHub Pages site for a repo.

## Installation

Go to your hubot and run:

```bash
npm install --save hubot-github-pages
```

Commit the changes to your `package.json` and push up to Heroku!

## Configuration

hubot-github-pages leans on [githubot][], which offers a few configuration
options:

|----------------------|----------|-------------------------------------------------------------------|
| Option               |          |                                                                   |
| `HUBOT_GITHUB_USER`  | Required | The GitHub username Hubot should use to authenticate with the API.|
| `HUBOT_GITHUB_TOKEN` | Required | The token used to authenticate against the GitHub API.            |
| `HUBOT_GITHUB_REPO`  | Optional | The default repo about which to ask questions.                    |
| `HUBOT_GITHUB_API`   | Optional | The URL of the GitHub API, with no trailing slash.                |

[githubot]: https://github.com/iangreenleaf/githubot

## Usage

Once hubot-github-pages is installed on your hubot, ask it things! The repo is
optional if `HUBOT_GITHUB_REPO` is set, otherwise you need it.

```bash
# Generally:
hubot pages <command> [repo] # fetch <command> about [repo]

# Specifically:
hubot pages info [repo] # fetch all info about repo (default: HUBOT_GITHUB_REPO)
hubot pages cname # fetch cname of the site
hubot pages latest # fetch latest build
hubot pages builds # fetch 
# ... etc
```

The allowed commands are as follows:

1. `info` - all [the info](http://developer.github.com/v3/repos/pages/#get-information-about-a-pages-site)
2. `status` - the status of the site
3. `cname` - the cname of the site
4. `custom_404` - whether the site has a custom 404 page
5. `builds` - the latest 30 builds
6. `latest` the latest build

## License

See LICENSE.
