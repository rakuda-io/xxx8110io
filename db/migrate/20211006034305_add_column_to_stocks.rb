class AddColumnToStocks < ActiveRecord::Migration[6.0]
  def up
    add_column :stocks, :company_name, :string
    add_column :stocks, :ticker_symbol, :string
    add_column :stocks, :country, :string
    add_column :stocks, :sector, :string
    add_column :stocks, :url, :string
  end
  def down
    remove_column :stocks, :company_name, :string
    remove_column :stocks, :ticker_symbol, :string
    remove_column :stocks, :country, :string
    remove_column :stocks, :sector, :string
    remove_column :stocks, :url, :string
  end
end
