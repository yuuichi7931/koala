# -*- encoding: utf-8 -*-
module Koala
  module Helpers
    include Rack::Utils
    alias_method :h, :escape_html

    def partial(page, locals = {}, options={})
      erb page.to_sym, options.merge!(:layout => false), locals
    end

    def formatted_date(date_string, delimiter='/')
      date_string = date_string.to_s
      return '' if date_string == ''
      date = Time.parse(date_string)
      date.strftime("%Y#{delimiter}%m#{delimiter}%d")
    end

    def formatted_rate(str)
      return $1 if /([\d\.]+)/ =~ str.to_s
      return ''
    end

    def add_wbr(s)
      string_array = s.to_s.split('<br />')
      formatted_string_array = []
      string_array.each do |string|
        formatted_string_array.push string.scan(/.{1,4}/).join("<wbr>")
      end
      return formatted_string_array.join("<br />")
    end

    def ranking_title(store_type, ranking_type, date, genre_name=nil)
      title = ""
      categories = {
        0 => {
        0 => 'トップ無料',
        1 => 'トップ有料',
        2 => 'トップセラー',
        3 => '新着',
      },
      1 => {
        0 => 'トップ無料',
        1 => 'トップ有料',
        2 => 'トップセラー',
        3 => '新着有料',
        4 => '新着無料',
      }
      }

      category = categories[store_type.to_i][ranking_type.to_i]
      if store_type.to_s=='0'
        title = "ランキング > App Store > #{category} ( #{date} )"
      else 
        title = "ランキング > Google Play > #{category} ( #{date} )"
      end

      if genre_name != nil && genre_name != ''
        title += " ジャンル: #{genre_name}"
      end

      return title
    end

    def get_genre(app)
      AppConfig::APP_STORE_RANKING_GENRES.each do |genre|
        if genre[:name]==app[:genre]
          return genre
        end
      end
      return nil
    end
  end

  helpers Helpers
end
