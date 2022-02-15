require "dotenv/load"
require "esa"

client = Esa::Client.new(current_team: ENV["ESA_TEAM_NAME"], access_token: ENV["ESA_ACCESS_TOKEN"])

posts = client.posts

p posts
