class Holding < ApplicationRecord
  belongs_to :stock
  belongs_to :user

  #個別にdividendを取得するためのインスタンスメソッド
  def get_current_dividend
    agent = Mechanize.new
    url = agent.get(Stock.find(self.stock_id).url)
    current_dividend_amount = url.search("td")[106].text.to_f
    current_dividend_rate = url.search("td")[118].text.to_f
    self.update!(
      dividend_amount: current_dividend_amount,
      dividend_rate: current_dividend_rate,
      total_dividend_amount: current_dividend_amount * self.quantity,
    )
  end

  #同じstock_idが該当userのholdingsに存在するか？を返すインスタンスメソッド
  def same_stock_id_exist?
    Holding.where(user_id: self.user_id).pluck(:stock_id).include?(self.stock_id)
  end

  private
    #メンテナンス用
    #全Holdingsにまとめて最新情報のdividendを取得するためのクラスメソッド
    def self.get_all_current_dividends
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
