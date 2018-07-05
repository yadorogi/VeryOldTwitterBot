#-----------------------------------------------------------------------------
# 「こばと。」 Twitter Bot
#
#    花戸小鳩　非公式bot
#    https://twitter.com/ko_bot
#
# Twitter Bot (つぶやきとウェルカムメッセージ用)
#
# ・フォローしている人をフォローし返す
# ・新たにフォローしてくれた人にウェルカムポストをする
# ・(コメントアウト)フォローを外した人をフォロー解除する
# ・通常のつぶやきを行う
# 
# 2010/06/01 (for @ko_bot) Tetsuo Kawakami
#-----------------------------------------------------------------------------


puts "*main_post.rb*"

Dir::chdir(File::dirname(__FILE__))
require 'twitter_bot.rb'

bot = TwitterBot.new('conf.yml')

puts "posted:"
p bot.post('post.xml')

puts 'finished.'
exit(0)