class Hospital < ApplicationRecord

  geocoded_by :address
  after_validation :geocode

  HEADER_VALUES = {
    organization:               'Organization',
    address:                    'Address',
    contact_name:               'Point of Contact Name',
    contact_email:              'Point of Contact Email',
    contact_phone:              'Point of Contact Phone',
    respirators:                'Respirators (N95 / PAPPR / CAPRS)',
    gowns:                      'Gowns',
    goggles:                    'Goggles / Safety Glasses',
    gloves:                     'Disposable gloves',
    sanitzer:                   'Unopened sanitizer',
    sample_collection_products: 'Sample collection products',
    hand_sewn_masks:            'Sample collection products',
    accepts_opened_ppe:         'Can accept opened PPE?',
  }.freeze

  def self.fetch_all
    # TODO cache with TTL

    results = GetMePpe::Spreadsheets.hospitals
    headers = results.values[1]
    indexes = HEADER_VALUES.keys.each_with_object({}) do |k, obj|
      obj[k] = headers.index { |a| a == HEADER_VALUES.fetch(k) }
    end

    results.values[2..-1].map do |result|
      organization = result[indexes[:organization]]
      next unless organization.present?

      args = HEADER_VALUES.keys.each_with_object({}) do |k, obj|
        obj[k] = result[indexes.fetch(k)]
      end

      find_or_initialize_by(organization: organization).tap do |hospital|
        args.each do |k, v|
          hospital.send("#{k}=", v)
        end
        hospital.save
      end
    end
  end

end
