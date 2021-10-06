class SortByColumnsToStocks < ActiveRecord::Migration[6.0]
  def change
    change_column :stocks, :company_name, :string, after: :id
    change_column :stocks, :ticker_symbol, :string, after: :company_name
    change_column :stocks, :country, :string, after: :ticker_symbol
    change_column :stocks, :sector, :string, after: :country
    change_column :stocks, :url, :string, after: :sector
  end
end
