class Province < ApplicationRecord
  DEFAULTS = [
    { code: "AB", name: "Alberta", gst_rate: 5.0, pst_rate: 0.0, hst_rate: 0.0, provincial_tax_name: "PST" },
    { code: "BC", name: "British Columbia", gst_rate: 5.0, pst_rate: 7.0, hst_rate: 0.0, provincial_tax_name: "PST" },
    { code: "MB", name: "Manitoba", gst_rate: 5.0, pst_rate: 7.0, hst_rate: 0.0, provincial_tax_name: "PST" },
    { code: "NB", name: "New Brunswick", gst_rate: 0.0, pst_rate: 0.0, hst_rate: 15.0, provincial_tax_name: "PST" },
    { code: "NL", name: "Newfoundland and Labrador", gst_rate: 0.0, pst_rate: 0.0, hst_rate: 15.0, provincial_tax_name: "PST" },
    { code: "NS", name: "Nova Scotia", gst_rate: 0.0, pst_rate: 0.0, hst_rate: 14.0, provincial_tax_name: "PST" },
    { code: "NT", name: "Northwest Territories", gst_rate: 5.0, pst_rate: 0.0, hst_rate: 0.0, provincial_tax_name: "PST" },
    { code: "NU", name: "Nunavut", gst_rate: 5.0, pst_rate: 0.0, hst_rate: 0.0, provincial_tax_name: "PST" },
    { code: "ON", name: "Ontario", gst_rate: 0.0, pst_rate: 0.0, hst_rate: 13.0, provincial_tax_name: "PST" },
    { code: "PE", name: "Prince Edward Island", gst_rate: 0.0, pst_rate: 0.0, hst_rate: 15.0, provincial_tax_name: "PST" },
    { code: "QC", name: "Quebec", gst_rate: 5.0, pst_rate: 9.975, hst_rate: 0.0, provincial_tax_name: "QST" },
    { code: "SK", name: "Saskatchewan", gst_rate: 5.0, pst_rate: 6.0, hst_rate: 0.0, provincial_tax_name: "PST" },
    { code: "YT", name: "Yukon", gst_rate: 5.0, pst_rate: 0.0, hst_rate: 0.0, provincial_tax_name: "PST" }
  ].freeze

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true, uniqueness: true
  validates :gst_rate, :pst_rate, :hst_rate, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :provincial_tax_name, presence: true

  scope :ordered, -> { order(:name) }

  def self.find_by_lookup(value)
    return if value.blank?

    normalized_value = value.to_s.strip.upcase

    find_by(code: normalized_value) ||
      find_by("UPPER(name) = ?", value.to_s.strip.upcase)
  end

  def total_tax_rate
    return hst_rate.to_d if hst_rate.to_d.positive?

    gst_rate.to_d + pst_rate.to_d
  end

  def tax_components
    return [{ name: "HST", rate: hst_rate.to_d }] if hst_rate.to_d.positive?

    [
      { name: "GST", rate: gst_rate.to_d },
      { name: provincial_tax_name, rate: pst_rate.to_d }
    ].select { |component| component[:rate].positive? }
  end

  def display_name
    "#{name} (#{code})"
  end

  def self.seed_defaults!
    DEFAULTS.each do |attributes|
      province = find_or_initialize_by(code: attributes[:code])
      province.update!(attributes)
    end
  end

  def self.ransackable_attributes(_auth_object = nil)
    ["code", "created_at", "gst_rate", "hst_rate", "id", "name", "provincial_tax_name", "pst_rate", "updated_at"]
  end
end
