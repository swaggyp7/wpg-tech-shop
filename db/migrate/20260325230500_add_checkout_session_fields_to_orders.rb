class AddCheckoutSessionFieldsToOrders < ActiveRecord::Migration[7.1]
  def change
    change_table :orders, bulk: true do |t|
      t.string :stripe_checkout_session_id
      t.text :stripe_checkout_url
      t.datetime :checkout_session_expires_at
      t.text :cart_signature
    end

    add_index :orders, :stripe_checkout_session_id, unique: true
  end
end
