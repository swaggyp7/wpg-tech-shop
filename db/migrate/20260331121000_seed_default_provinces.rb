class SeedDefaultProvinces < ActiveRecord::Migration[7.1]
  def up
    Province.reset_column_information
    Province.seed_defaults!
  end

  def down
    Province.where(code: Province::DEFAULTS.map { |province| province[:code] }).delete_all
  end
end
