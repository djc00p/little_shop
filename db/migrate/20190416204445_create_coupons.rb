class CreateCoupons < ActiveRecord::Migration[5.1]
  def change
    create_table :coupons do |t|
      t.string :name
      t.integer :dollars_off
      t.boolean :active, default: false

      t.timestamps
    end
  end
end
