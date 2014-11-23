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
#   hubot pages info [repo] - fetch all GHP info (not build info) about repo (default: HUBOT_GITHUB_REPO)
#   hubot pages status [repo] - fetch the build status
#   hubot pages cname [repo] - fetch cname
#   hubot pages custom_404 [repo] - fetch whether there's a custom 404 page
#   hubot pages latest [repo] - fetch latest build
#   hubot pages builds [repo] - fetch the latest 30 builds
#   hubot pages version - display the gem versions currently running on GitHub Pages
#
# Notes:
#   Per the GitHub API, you must be the owner of the repo in question.
#
# Author:
#   parkr

timeago = require('timeago')

INFO_KEYS        = ["cname", "status", "custom_404"]
INFO_COMMANDS    = ["info"].concat(INFO_KEYS)
BUILD_COMMANDS   = ["builds"]
LATEST_COMMANDS  = ["latest"]
VERSION_COMMANDS = ["versions", "ver"]
ALLOWED_COMMANDS = INFO_COMMANDS.concat(BUILD_COMMANDS).concat(LATEST_COMMANDS).concat(VERSION_COMMANDS)

endpoint = (repo, command) ->
  base = "repos/#{repo}/pages"
  if command in INFO_COMMANDS
    base
  else if command in BUILD_COMMANDS
    "#{base}/builds"
  else if command in LATEST_COMMANDS
    "#{base}/builds/latest"
  else if command in VERSION_COMMANDS
    "https://pages.github.com/versions.json"

github_pages_info = (githubot, repo, command, cb) ->
  githubot.handleErrors (response) ->
    console.log "Error fetching info about GitHub Pages site for #{repo}: #{reponse.statusCode} #{response.error}"

  githubot.get endpoint(repo, command), {}, cb

fetch_from_info = (info, command) ->
  if command in INFO_KEYS
    info[command]
  else
    info

formatted_build_text = (build) ->
  "Page build #{build.status} @ #{build.commit.substr(0, 7)}. Triggered by #{build.pusher.login} #{timeago(build.created_at)}."

formatted_versions = (versions) ->
  all = for gem, version of versions
    "#{gem} v#{version}"
  all.join("\n")

module.exports = (robot) ->
  github = require("githubot")(robot)
  robot.respond /pages (\w+)( \w+\/[\w\.]+)?/i, (msg) ->
    command   = msg.match[1]
    repo      = github.qualified_repo msg.match[2]

    unless command in ALLOWED_COMMANDS
      msg.send "Sorry, what was that? '#{command}' isn't a recognized command."
      return

    cb = null
    if command in INFO_COMMANDS
      cb = (info) ->
        msg.send "No info found for '#{repo}'." unless info?
        msg.send JSON.stringify fetch_from_info(info, command)
    else if command in BUILD_COMMANDS
      cb = (info) ->
        msg.send "No info found for '#{repo}'." unless info?
        msg.send (formatted_build_text(build) for build in info).join("\n")
    else if command in LATEST_COMMANDS
      cb = (info) ->
        msg.send "No info found for '#{repo}'." unless info?
        msg.send formatted_build_text info
    else if command in VERSION_COMMANDS
      cb = (info) ->
        msg.send "No versions found. Is GitHub.com up?" unless info?
        msg.send formatted_versions(info)

    github_pages_info github, repo, command, cb
