# Description:
#   Let hubot fetch info about the GitHub Pages site for a repo.
#
# Dependencies:
#   githubot 0.5.x
#
# Configuration:
#   HUBOT_GITHUB_API
#   HUBOT_GITHUB_USER
#   HUBOT_GITHUB_TOKEN
#   HUBOT_GITHUB_REPO - the default repo
#
# Commands:
#   hubot pages <command> [repo] - fetch <command> about [repo]
#   hubot pages info [repo] - fetch all info about repo (default: HUBOT_GITHUB_REPO)
#   hubot pages cname - fetch cname of 
#   hubot pages latest - fetch latest build
#   hubot pages builds - fetch 
#
# Author:
#   parkr

timeago = require('timeago')

INFO_KEYS       = ["cname", "status", "custom_404"]
INFO_COMMANDS   = ["info"] + INFO_KEYS
BUILD_COMMANDS  = ["builds"]
LATEST_COMMANDS = ["latest"]

endpoint = (repo, command) ->
  base = "/repos/#{repo}/pages"
  if command in INFO_COMMANDS
    base
  else if command in BUILD_COMMANDS
    "#{base}/builds"
  else if command in LATEST_COMMANDS
    "#{base}/builds/latest"

github_pages_info = (githubot, repo, command) ->
  githubot.get endpoint(repo, command), (info) ->
    info

fetch_from_info = (githubot, repo, command) ->
  info = github_pages_info(githubot, repo, command)
  if command in INFO_KEYS
    info[command]
  else
    info

formatted_build_text = (build) ->
  "Page build #{build.status}@#{build.commit.substr(0, 7)} Triggered by #{build.pusher} at #{timeago(build.created_at)}."

module.exports = (robot) ->
  github = require("githubot")(robot)
  robot.respond /pages (\w+)( \w+\/\w+)?/i, (msg) ->
    command   = msg.match[1].strip()
    repo      = github.qualified_repo msg.match[2]

    github.handleErrors (response) ->
      msg.send "Error fetching info about GitHub Pages site for #{repo}: #{response.error}"

    if command in INFO_COMMANDS
      msg.send fetch_from_info(command)
    else if command in BUILD_COMMANDS
      info = github_pages_info(github, repo, command)
      msg.send (formatted_build_text(build) for build in info).join("\n")
    else if command in LATEST_COMMANDS
      info = github_pages_info(github, repo, command)
      msg.send formatted_build_text(info)
