#!/usr/bin/env ruby
# coding: utf-8

#-----------------------------------------------------------------------------
# 「こばと。」 Twitter Bot
#
#    花戸小鳩　非公式bot
#    https://twitter.com/ko_bot
#
# 2010/06/01 (for @ko_bot) Tetsuo Kawakami
#-----------------------------------------------------------------------------

require 'rubygems'
require 'oauth'
#require 'oauth-patch'

CONSUMER_KEY = 'XXXXXXXXXXXXXXXXX' # ←ここを書き換える
CONSUMER_SECRET = 'XXXXXXXXXXXXXX' # ←ここを書き換える

consumer = OAuth::Consumer.new(
  CONSUMER_KEY,
  CONSUMER_SECRET,
  :site => 'http://twitter.com'
)

request_token = consumer.get_request_token

puts "Access this URL and approve => #{request_token.authorize_url}"

print "Input OAuth Verifier: "
oauth_verifier = gets.chomp.strip

access_token = request_token.get_access_token(
  :oauth_verifier => oauth_verifier
)

puts "Access token: #{access_token.token}"
puts "Access token secret: #{access_token.secret}"