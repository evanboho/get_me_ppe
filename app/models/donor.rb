class Donor < ApplicationRecord

  geocoded_by :address
  after_validation :geocode

  HEADER_VALUES = {
    name:                       'Name',
    email_address:              'Email Address',
    phone_number:               'Mobile phone number',
    address_street:             'Home address: Street name and number (nearby cross-streets are okay; e.g. 24th and Mission)',
    address_city:               'Home address: City',
    address_zip:                'Home Address: Zip Code',
  }.freeze

  def self.fetch_all
    results = GetMePpe::Spreadsheets.donors
    headers = results.values[0]
    indexes = HEADER_VALUES.keys.each_with_object({}) do |k, obj|
      obj[k] = headers.index { |a| a == HEADER_VALUES.fetch(k) }
    end

    results.values[1..-1].map do |result|
      name = result[indexes[:name]]
      next unless name.present?

      args = HEADER_VALUES.keys.each_with_object({}) do |k, obj|
        obj[k] = result[indexes.fetch(k)]
      end

      args[:address] = "#{args.delete :address_street}, #{args.delete :address_city}, #{args.delete :address_zip}"

      find_or_initialize_by(name: name).tap do |donor|
        args.each do |k, v|
          donor.send("#{k}=", v)
        end
        donor.save
      end
    end
  end

end
