class Holding < ApplicationRecord
  belongs_to :stock
  belongs_to :user

  private
    #メンテナンス用
    #全Holdingsをまとめて最新情報のdividend等を取得
    def self.get_current_dividend
      agent = Mechanize.new
      holdings = Holding.all
      holdings.map { |holding|
        url = agent.get(holding.stock.url)
        current_dividend_amount = url.search("td")[106].text.to_f
        current_dividend_rate = url.search("td")[118].text.to_f
        holding.update!(
          dividend_amount: current_dividend_amount,
          dividend_rate: current_dividend_rate,
          total_dividend_amount: current_dividend_amount * holding.quantity,
        )
      }
    end
end
