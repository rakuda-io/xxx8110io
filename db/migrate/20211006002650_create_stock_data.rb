class CreateStockData < ActiveRecord::Migration[6.0]
  def change
    create_table :stock_data do |t|

      t.timestamps
    end
  end
end
