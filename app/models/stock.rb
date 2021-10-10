class Stock < ApplicationRecord
  # レコードにエラー情報（ActiveRecordのerror）が付加される
  has_many :holdings, dependent: :restrict_with_error

  validates :ticker_symbol, presence: true

  # finviz.comから最新の株データを取得するためのメソッド
  def self.fetch_all_stocks_data
    agent = Mechanize.new
    next_url = "" # ページネーションのURL保存
    page = 1 # デバッグ用

    # Nextリンクがなくなるまで繰り返す
    loop do
      Rails.logger.debug { "●●●●●●●●●●●●●●● #{page} ページ目 ●●●●●●●●●●●●●●●" } # デバッグ用
      page += 1 # デバッグ用

      # 一覧ページ（current_page）のデータを一時的に取得
      current_page = agent.get("https://finviz.com/screener.ashx?v=111#{next_url}")
      tickers = current_page.search(".screener-link-primary").map(&:text)
      urls = current_page.search(".screener-body-table-nw a").map { |url| url.get_attribute('href') }.uniq

      # 取得した一覧ページのデータを使って個別ページ（detailed_page）のデータを取得して各カラムに保存
      tickers.zip(urls) do |ticker, url|
        detailed_page = agent.get(url)
        company_name = detailed_page.search("td")[29].text
        sector = detailed_page.search("td")[30].search("a").first.text
        country = detailed_page.search("td")[30].search("a").last.text
        create!(
          ticker_symbol: ticker,
          url: "https://finviz.com/#{url}",
          company_name: company_name,
          sector: sector,
          country: country
        )
      end

      # 次ページのリンクを取得して変数next_linkに次ページURLの必要部分のみを正規表現で取り出し代入
      # nextページネーションがなかったらbreakさせる（すなわち最後のページネーションまで全データ取り込み完了）
      next_link = current_page.at(".screener_pagination a:last-child")
      if next_link.text == "next"
        next_url = next_link.get_attribute('href').match(/&.+/).to_s
      else
        Rails.logger.debug "●●●●●●●●●●●●●●● 全データ取り込み完了 ●●●●●●●●●●●●●●● "
        break
      end
    end
  end
end
