require 'csv'

module CsvHelper

  def to_csv(objects)
    objects_csv_hash = objects.each_with_object([]) do |object, arr|
      next unless object.valid_for_csv?

      arr << self::CSV_MAPPING.each_with_object({}) do |(csv_field, object_field), obj|
        if object_field.is_a?(Symbol)
          obj[csv_field] = object.send(object_field)
        else
          obj[csv_field] = object_field
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
