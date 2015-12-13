# coding: utf-8
# シングルトンのtwitterクライアントクラス
require 'bundler'
require 'yaml'
require 'singleton'
Bundler.require

Dotenv.load

class BotTwitterClient
  include Singleton

  attr_accessor :client
  def initialize
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
      config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
      config.access_token        = ENV["TWITTER_ACCESS_TOKEN"]
      config.access_token_secret = ENV["TWITTER_ACCESS_SECRET"]
    end
  end
end

# twitterクライアントを生成する
def createclient()
  twitterclient = BotTwitterClient.instance

  return twitterclient.client
end
