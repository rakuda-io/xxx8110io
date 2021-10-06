class CreateHoldings < ActiveRecord::Migration[6.0]
  def change
    create_table :holdings do |t|

      t.timestamps
    end
  end
end
