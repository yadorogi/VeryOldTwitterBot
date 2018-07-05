#-----------------------------------------------------------------------------
# 「こばと。」 Twitter Bot
#
#    花戸小鳩　非公式bot
#    https://twitter.com/ko_bot
#
#  Filename : twitter_bot.rb
#
#   ・ひとりごとをつぶやく
#   ・自分宛のメッセージを解析して返信を行う
#   ・特定のメッセージをお気に入りにする
#
# なおすべてのメッセージは、
#   ・#user_name#をユーザー名
#   ・#date#を今日の◯月◯日に
#   ・#time#を今の◯時◯分に
# それぞれ置換されたメッセージをポストする
#
# 2010/06/01 (for @ko_bot) Tetsuo Kawakami
#-----------------------------------------------------------------------------

require 'yaml'
require 'rubygems'
require 'twitter'
require "time"

class TwitterBot

# 設定ファイルの読み込み
#-----------------------------------------------------------------------------
  public
  def initialize(conf_file)

    @conf = YAML::load(File.read(conf_file))
    @client = create_client
  end
#-----------------------------------------------------------------------------


#-----------------------------------------------------------------------------
# ひとりごとをポスト
# メッセージのXMLの形式は以下の通り
#
# <?xml version='1.0' encoding='UTF-8'?>
# <post>
#   <comment last_time='1262509457' count='22' content='メッセージ'/>
# </post>
#
#-----------------------------------------------------------------------------
  def post(xml_file)

    doc_post = REXML::Document.new(File.read(xml_file))
    comments = doc_post.root().get_elements('comment')

    comment = nil
    if @conf['bot']['post_random']
      comment = comments[rand(comments.length)]
    else
      comment = most_unused_comment(comments)
    end

    message = replace_token(comment, '')

# テスト
s_message = Kconv.kconv(message, Kconv::SJIS)
puts s_message
# テスト

    @client.update(Kconv.kconv(message,
      Kconv::UTF8))

    update_comment_attr(comment)
    save_xml(doc_post, xml_file)

    comment

  end
#-----------------------------------------------------------------------------





#-----------------------------------------------------------------------------
# 指定された時間内のポスト解析をして、引っかかるキーワードがあれば返信、
# 返信したポストのIDの配列を返す
# メッセージのXMLの形式は以下の通り。#user_name#をユーザー名と置換
#
#<?xml version='1.0' encoding='UTF-8'?>
#<reply>
#    <keyword term='アイシャ'>
#        <comment last_time='1262510469' content='ありがとう！#user_name#も頑張ってね！' count='7'/>
#        <comment last_time='1262498652' content='わたしも頑張るね！#user_name#も頑張ってね！' count='6'/>
#    </keyword>
#</reply>
#
  def reply(xml_file, replied_comment_ids=[], isUseCache=false)
    reply_internal(xml_file, false, replied_comment_ids, isUseCache)
  end
#-----------------------------------------------------------------------------





#-----------------------------------------------------------------------------
# 自分宛のポスト解析をして、引っかかるキーワードがあれば返信、
# 返信したポストのIDの配列を返す
# メッセージのXMLの形式は以下の通り。#user_name#をユーザー名と置換
#
# キャッシュを使うと設定だと、reply系を繰り返すとき新規に情報を取得しませんが
# リクエスト数を減らすことができます。(twitterの1時間150リクエストの制限)
#
#<?xml version='1.0' encoding='UTF-8'?>
#<reply>
#    <keyword term='アイシャ'>
#        <comment last_time='1262510469' content='ありがとう！#user_name#も頑張ってね！' count='7'/>
#        <comment last_time='1262498652' content='わたしも頑張るね！#user_name#も頑張ってね！' count='6'/>
#    </keyword>
#</reply>
#
#-----------------------------------------------------------------------------
  def reply_for_me(xml_file, replied_comment_ids=[], isUseCache=false)
    reply_internal(xml_file, true, replied_comment_ids, isUseCache)
  end
#-----------------------------------------------------------------------------


#-----------------------------------------------------------------------------
# 渡されたidの配列のポストをすべてお気に入りににする
#-----------------------------------------------------------------------------
#  def favorite(ids)
#    ids.each{|id|
#      begin
#        @client.favorite_create(id)
#      rescue => ex
#        print ex.message, "\n"
#      end
#      }
#    ids
#  end
#-----------------------------------------------------------------------------


#-----------------------------------------------------------------------------
  private
  # twitterクライアントの作成
  def create_client

    oauth_bot_conf = @conf['bot']['oauth']
    oauth = Twitter::OAuth.new(
      oauth_bot_conf['consumer_key'],
      oauth_bot_conf['consumer_secret']
      )
    oauth.authorize_from_access(
      oauth_bot_conf['token'],
      oauth_bot_conf['secret']
    )
    Twitter::Base.new(oauth)
  end
#-----------------------------------------------------------------------------


#-----------------------------------------------------------------------------
# comment要素配列の中で最も古くてポスト回数が少ないものを取得
#-----------------------------------------------------------------------------
  def most_unused_comment(comments)

# テスト
puts "Debug Message:most_unused_comment"
s_message = Kconv.kconv("comment要素配列の中で最も古くてポスト回数が少ないものを取得", Kconv::SJIS)
puts s_message
# テスト

      # コメント配列をポスト回数・日付順に破壊的ソート
      comments.sort! { |a,b|
        a.attributes.get_attribute('last_time').to_s.to_i <=>
          b.attributes.get_attribute('last_time').to_s.to_i
      }.sort! { |a,b|
        a.attributes.get_attribute('count').to_s.to_i <=>
          b.attributes.get_attribute('count').to_s.to_i
      }
      comments[0]
  end
#-----------------------------------------------------------------------------


#-----------------------------------------------------------------------------
# comment要素の更新日時とカウントを更新
#-----------------------------------------------------------------------------
  def update_comment_attr(comment)

# テスト
puts "Debug Message:update_comment_attr"
s_message = Kconv.kconv("comment要素の更新日時とカウントを更新", Kconv::SJIS)
puts s_message
# テスト

    count = comment.attributes.get_attribute('count').to_s.to_i + 1
    comment.delete_attribute('count')
    comment.add_attribute('count', count.to_s)
    comment.delete_attribute('last_time')
    comment.add_attribute('last_time', Time.now.to_i.to_s)
    comment
  end


#-----------------------------------------------------------------------------
# ファイルにxmlのdomを保存する
#-----------------------------------------------------------------------------
  def save_xml(doc_post, xml_file)

# テスト
puts "Debug Message:save_xml"
s_message = Kconv.kconv("ファイルにxmlのdomを保存する", Kconv::SJIS)
puts s_message
# テスト

    io = open(xml_file,'w')
    doc_post.write(io)
    io.close
  end
#-----------------------------------------------------------------------------


#-----------------------------------------------------------------------------
  # ・#user_name#をユーザー名
  # ・#date#を今日の◯月◯日に
  # ・#time#を今の◯時◯分に
  # それぞれ置換されたメッセージを取得する
#-----------------------------------------------------------------------------
  def replace_token(comment, user_name)

# テスト
puts "Debug Message:replace_token"
s_message = Kconv.kconv("ユーザー名、日時、それぞれ置換されたメッセージを取得する", Kconv::SJIS)
puts s_message
# テスト

    name_replaced_message = comment.attributes.get_attribute('content').to_s
    name_replaced_message = name_replaced_message.gsub(/#user_name#/, user_name)
    today = Time.now
    name_replaced_message =
      name_replaced_message.gsub(/#date#/,
      today.month.to_s + "月" + today.day.to_s + "日")
    name_replaced_message =
      name_replaced_message.gsub(/#time#/,
      today.hour.to_s + "時" + today.min.to_s + "分")
    name_replaced_message
  end
#-----------------------------------------------------------------------------


#-----------------------------------------------------------------------------
# xmlから返信する処理を行う処理の内部実装
#-----------------------------------------------------------------------------
  def reply_internal(xml_file, is_for_me, replied_comment_ids, isUseCache)

# テスト
puts "Debug Message:reply_internal"
s_message = Kconv.kconv("xmlから返信する処理を行う処理の内部実装", Kconv::SJIS)
puts s_message
# テスト

    replied_comment_ids = replied_comment_ids.dup
    doc_rep = nil

    # キャッシュを使わないなら必ずリクエスト、使う設定でも変数がnilならリクエスト
    @friends_timeline = @client.friends_timeline if !isUseCache || @friends_timeline == nil

    @friends_timeline.each{|mash|

      if is_for_me
        # もし自分あての返信でなければパス
        reg = Regexp.new("^@" + @conf['bot']['login'])
        next if reg.match(mash.text) == nil
      end

      # インターバル時間より前のコメントはパス
      next if Time.parse(mash.created_at) < Time.at(Time.now.to_i - @conf['bot']['interval'])
      # 自分の投稿はパス
      next if mash.user.screen_name == @conf['bot']['login']

      doc_rep = REXML::Document.new(File.read(xml_file)) if doc_rep == nil

      doc_rep.root.elements.each{|k|

        # 既に返信済のポストはパス
        next if replied_comment_ids.include?(mash.id)

        term = k.attributes.get_attribute('term').to_s
        # 一つ一つのキーワードに関して、そのキーワードを含んでいるか
        next if !mash.text.include?(term)

        comments = k.get_elements('comment')
        comment = nil
        if @conf['bot']['post_random']
         comment = comments[rand(comments.length)]
        else
         comment = most_unused_comment(comments)
        end

        name_replaced_message = replace_token(comment, mash.user.name)
        @client.update(Kconv.kconv(
            "@" + mash.user.screen_name + " " + name_replaced_message,
            Kconv::UTF8 ),
        {:in_reply_to_status_id => mash.id })

        update_comment_attr(comment)
        replied_comment_ids << mash.id
      }
    }

    save_xml(doc_rep, xml_file) if doc_rep != nil
    replied_comment_ids
  end
#-----------------------------------------------------------------------------

end
