# coding: utf-8
require 'bundler'
Bundler.require
require 'yaml'
require 'optparse'

require_relative 'lib/bottwitterclient'

currentdir = File.dirname(__FILE__)
Dotenv.load

# コマンドラインオプション解析
def cmdline
  args = {}

  OptionParser.new do |parser|
    parser.on('-g', '--graphonly', 'グラフ生成のみ') {|v| args[:graphonly] = v}
    parser.on('-b PATH', '--bgimage', '背景画像を指定') {|v| args[:bgimage] = v}
    parser.parse!(ARGV)
  end

  return args
end

args = cmdline

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

# グラフのテーマ指定
if args[:bgimage] && File.exists?(args[:bgimage]) then
  bgImage = args[:bgimage]

  defaultsTheme = {
    :colors => ['orange', 'white'],
    :additional_line_colors => [],
    :marker_color => 'blue',
    :font_color => 'blue',
    :background_colors => nil,
    :background_image => bgImage
  }

  g.theme = defaultsTheme
end

graphimgpath = File.join(currentdir,'ranking_graph.png')
g.write(graphimgpath)

sleep(1)

unless args[:graphonly] then
  #グラフを投稿する
  tweetText = ENV["TWEET_TEXT"] || "みんながぼくのおむつを交換してくれた回数を、パパがグラフにしてくれたよ。"
  File.open(graphimgpath, 'rb') do |f|
    createclient.update_with_media(tweetText, f)
  end
end
