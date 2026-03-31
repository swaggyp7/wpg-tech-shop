module TaxCalculations
  extend ActiveSupport::Concern

  def tax_rate
    tax_components.sum { |component| component[:rate] } / 100
  end

  def tax_amount
    (grand_total - subtotal.to_d).round(2)
  end

  def grand_total
    return total_price.to_d.round(2) if respond_to?(:total_price) && total_price.present? && total_price.to_d >= subtotal.to_d

    calculated_grand_total
  end

  def tax_label
    return "Taxes" if tax_components.empty?

    "Taxes (#{tax_components.map { |component| "#{component[:name]} #{format_tax_rate(component[:rate])}" }.join(" + ")})"
  end

  private

  def calculated_grand_total
    (subtotal.to_d + calculated_tax_amount).round(2)
  end

  def calculated_tax_amount
    (subtotal.to_d * tax_rate).round(2)
  end

  def tax_components
    return snapshot_tax_components if snapshot_tax_rates_present?
    return tax_profile.tax_components if respond_to?(:tax_profile) && tax_profile.present?

    []
  end

  def snapshot_tax_components
    if snapshot_hst_rate.positive?
      [{ name: "HST", rate: snapshot_hst_rate }]
    else
      [
        { name: "GST", rate: snapshot_gst_rate },
        { name: snapshot_provincial_tax_name, rate: snapshot_pst_rate }
      ].select { |component| component[:rate].positive? }
    end
  end

  def snapshot_gst_rate
    snapshot_decimal(:gst_rate_snapshot)
  end

  def snapshot_pst_rate
    snapshot_decimal(:pst_rate_snapshot)
  end

  def snapshot_hst_rate
    snapshot_decimal(:hst_rate_snapshot)
  end

  def snapshot_provincial_tax_name
    return self[:provincial_tax_name_snapshot] if respond_to?(:[]) && self[:provincial_tax_name_snapshot].present?

    "PST"
  end

  def snapshot_decimal(attribute)
    return 0.to_d unless respond_to?(:[]) && self[attribute].present?

    self[attribute].to_d
  end

  def snapshot_tax_rates_present?
    snapshot_gst_rate.positive? || snapshot_pst_rate.positive? || snapshot_hst_rate.positive?
  end

  def format_tax_rate(rate)
    "#{rate.to_d.to_s("F").sub(/\.?0+\z/, "")}%"
  end
end
