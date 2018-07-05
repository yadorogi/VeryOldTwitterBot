#-----------------------------------------------------------------------------
# 「こばと。」 Twitter Bot
#
#    花戸小鳩　非公式bot
#    https://twitter.com/ko_bot
#
# Twitter Bot スクリプト(返信用)
# 自分宛返信優先で、XMLの上部から最初にヒットしたキーワードのポストを返信。
# 一度返信したポストには二度返信はしない。
#
# ・自分宛のメッセージを解析して返信を行う
# ・ポスト解析して返信を行う
# ・(コメントアウト)自分宛のメッセージをお気に入りに登録する
#
# 2010/06/01 (for @ko_bot) Tetsuo Kawakami
#-----------------------------------------------------------------------------

Dir::chdir(File::dirname(__FILE__))
require 'twitter_bot.rb'

bot = TwitterBot.new('conf.yml')

#自分宛のリプライを取得する
puts 'replied_post_for_me_ids:'
replied_comment_ids = bot.reply_for_me('reply_for_me.xml')
p replied_comment_ids

#リプライをポストする
puts 'replied_post_ids:'
p bot.reply('reply.xml', replied_comment_ids, true) - replied_comment_ids
 
#puts 'favorite_ids:'
#p bot.favorite(replied_comment_ids)

puts 'finished.'
exit(0)