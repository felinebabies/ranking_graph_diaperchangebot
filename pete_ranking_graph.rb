# coding: utf-8
require 'bundler'
Bundler.require
require 'yaml'

g = Gruff::SideStackedBar.new
g.title = "ぼくのおむつ替えランキング"

g.font = "C:/WINDOWS/Fonts/MSGOTHIC.TTC"
g.y_axis_increment = 20
g.marker_font_size = 10

rankingData = YAML.load_file("./userdata.yml")
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

g.write('ranking_graph.png')
