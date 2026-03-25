# frozen_string_literal: true

class AddDeviseToCustomers < ActiveRecord::Migration[7.1]
  def self.up
    change_column_default :customers, :email, from: nil, to: ""
    change_column_null :customers, :email, false, ""

    add_column :customers, :encrypted_password, :string, null: false, default: "" unless column_exists?(:customers, :encrypted_password)

    ## Recoverable
    add_column :customers, :reset_password_token, :string unless column_exists?(:customers, :reset_password_token)
    add_column :customers, :reset_password_sent_at, :datetime unless column_exists?(:customers, :reset_password_sent_at)

    ## Rememberable
    add_column :customers, :remember_created_at, :datetime unless column_exists?(:customers, :remember_created_at)

    add_index :customers, :email, unique: true unless index_exists?(:customers, :email)
    add_index :customers, :reset_password_token, unique: true unless index_exists?(:customers, :reset_password_token)
    # add_index :customers, :confirmation_token,   unique: true
    # add_index :customers, :unlock_token,         unique: true
  end

  def self.down
    # By default, we don't want to make any assumption about how to roll back a migration when your
    # model already existed. Please edit below which fields you would like to remove in this migration.
    raise ActiveRecord::IrreversibleMigration
  end
end
