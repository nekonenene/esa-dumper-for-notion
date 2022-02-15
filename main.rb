require "dotenv/load"
require "esa"
require "fileutils"
require "time"

json_dir = "export/json"
html_dir = "export/html"
markdown_dir = "export/markdown"
FileUtils.mkdir_p json_dir
FileUtils.mkdir_p html_dir
FileUtils.mkdir_p markdown_dir

client = Esa::Client.new(current_team: ENV["ESA_TEAM_NAME"], access_token: ENV["ESA_ACCESS_TOKEN"])
page = 1

loop do
  response = client.posts(include: "comments", sort: "created", order: "asc", per_page: 100, page: page)
  body = response.body
  page = body["page"]
  next_page = body["next_page"] # nil になったとき、もう次のページは存在しない
  posts = body["posts"]
  posts_json = posts.to_json

  File.open("#{json_dir}/posts_#{page}.json", mode = "w") do |f|
    f.write(posts_json)
  end

  posts.each do |post|
    full_name = post["full_name"]
    file_name = full_name.gsub("/", "::")
    body_md = post["body_md"]
    body_html = post["body_html"]

    id = post["number"]
    category = post["category"]
    created_at = Time.parse(post["created_at"])
    updated_at = Time.parse(post["updated_at"])
    created_by = "#{post["created_by"]["name"]} (#{post["created_by"]["screen_name"]})"
    updated_by = "#{post["updated_by"]["name"]} (#{post["updated_by"]["screen_name"]})"

    comments_count = post["comments_count"]
    comments = post["comments"]

    md_str =
      "* ID: #{id}\n" \
      "* category: #{category}\n" \
      "* 作成時刻: #{created_at.strftime("%Y/%m/%d %H:%M:%S")} by #{created_by}\n" \
      "* 更新時刻: #{updated_at.strftime("%Y/%m/%d %H:%M:%S")} by #{updated_by}\n" \
      "\n- - -\n\n"
    md_str += body_md

    html_str =
      "<ul>" \
      "<li>ID: #{id}</li>" \
      "<li>category: #{category}</li>" \
      "<li>作成時刻: #{created_at.strftime("%Y/%m/%d %H:%M:%S")} by #{created_by}</li>" \
      "<li>更新時刻: #{updated_at.strftime("%Y/%m/%d %H:%M:%S")} by #{updated_by}</li>" \
      "</ul>" \
      "<hr>"

    # タイトル部分が <span class="hidden" data-text="たいとる"> &gt; たいとる</span> のようになっている箇所があるので削除しているが
    # <span class="hidden"><b>たいとる</b></span> のようになっている箇所では誤動作してしまう問題がある
    removed_hidden_html = body_html.gsub(%r{<[^<]*class="hidden"[^>]*>[^<]*</[^>]+>}, "")
    html_str += removed_hidden_html

    md_str += "\n\n- - -\n\n## コメント一覧\n\n" if comments_count > 0
    html_str += "<hr><h2>コメント一覧</h2>" if comments_count > 0
    comments.each do |comment|
      comment_created_at = Time.parse(comment["created_at"])
      comment_created_by = "#{comment["created_by"]["name"]} (#{comment["created_by"]["screen_name"]})"

      md_str += "### #{comment_created_by} at #{comment_created_at.strftime("%Y/%m/%d %H:%M:%S")}\n\n"
      md_str += comment["body_md"] + "\n\n"
      html_str += "<h3>#{comment_created_by} at #{comment_created_at.strftime("%Y/%m/%d %H:%M:%S")}</h3>"
      html_str += comment["body_html"]
    end

    File.open("#{markdown_dir}/#{file_name}.md", mode = "w") do |f|
      f.write(md_str)
    end
    File.open("#{html_dir}/#{file_name}.html", mode = "w") do |f|
      f.write(html_str)
    end
  end

  puts "next_page: #{next_page}"
  break if next_page.nil? || page == 1 # いったんテスト用に page = 1 で終わるように
end

puts "Successfully completed!!"
