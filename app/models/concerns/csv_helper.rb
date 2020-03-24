require 'csv'

module CsvHelper
  extend ActiveSupport::Concern

  def to_csv(objects)
    objects_csv_hash = objects.each_with_object([]) do |donor, arr|
      arr << self::CSV_MAPPING.each_with_object({}) do |(csv_field, donor_field), obj|
        if donor_field.is_a?(Symbol)
          obj[csv_field] = donor.send(donor_field)
        else
          obj[csv_field] = donor_field
        end
      end
    end

    CSV.generate do |csv|
      csv << self::CSV_MAPPING.keys
      objects_csv_hash.each do |row|
        csv << row.values
      end
    end

  end

end
