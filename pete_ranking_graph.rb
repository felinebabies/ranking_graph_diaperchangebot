# coding: utf-8
require 'bundler'
Bundler.require
require 'yaml'

require_relative 'lib/bottwitterclient'

currentdir = File.dirname(__FILE__)
Dotenv.load

#対象ファイル指定
if(ARGV[0]) then
  targetFile = ARGV[0]
else
  targetFile = "./userdata.yml"
end

# ファイルが存在しなければ終了
unless File.exist?(targetFile) then
  puts "File [#{targetFile}] not exists."
  exit
end

g = Gruff::SideStackedBar.new
g.title = "ぼくのおむつ替えランキング"

fontname = ENV["RENDER_FONT_NAME"] || "mplus-1p-medium.ttf"
g.font = File.join(currentdir,fontname)
g.y_axis_increment = 20
g.marker_font_size = 10

rankingData = YAML.load_file(targetFile)
rankingData.sort! do |a, b|
  b["diaperchangepoint"] <=> a["diaperchangepoint"]
end

changeCount = []
labels = {}
rankingData.each_with_index do |data, i|
  changeCount << data["diaperchangepoint"]
  labels[i] = data["displayname"]
end

g.data 'おむつ交換数', changeCount
g.labels = labels

graphimgpath = File.join(currentdir,'ranking_graph.png')
g.write(graphimgpath)

sleep(1)

#グラフを投稿する
tweetText = ENV["TWEET_TEXT"] || "みんながぼくのおむつを交換してくれた回数を、パパがグラフにしてくれたよ。"
File.open(graphimgpath, 'rb') do |f|
  createclient.update_with_media(tweetText, f)
end
