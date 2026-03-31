class CreateProvincesAndAddTaxSnapshotsToOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :provinces do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.decimal :gst_rate, precision: 6, scale: 3, null: false, default: 0
      t.decimal :pst_rate, precision: 6, scale: 3, null: false, default: 0
      t.decimal :hst_rate, precision: 6, scale: 3, null: false, default: 0
      t.string :provincial_tax_name, null: false, default: "PST"

      t.timestamps
    end

    add_index :provinces, :code, unique: true
    add_index :provinces, :name, unique: true

    change_table :orders, bulk: true do |t|
      t.string :province_code_snapshot
      t.decimal :gst_rate_snapshot, precision: 6, scale: 3
      t.decimal :pst_rate_snapshot, precision: 6, scale: 3
      t.decimal :hst_rate_snapshot, precision: 6, scale: 3
      t.string :provincial_tax_name_snapshot
    end
  end
end
