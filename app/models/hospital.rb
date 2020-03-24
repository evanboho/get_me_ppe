require 'concerns/csv_helper'

class Hospital < ApplicationRecord

  extend CsvHelper

  geocoded_by :address
  before_validation :set_address
  after_validation :geocode

  HEADER_VALUES = {
    organization:               'Organization (bold: regional)',
    address:                    'Dropoff Address (Map here: https://drive.google.com/open?id=1XKSENq4VZr5oa5PFc25J_bslfDCjqfRK&usp=sharing)',
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
    notes:                      'Notes',
  }.freeze

  CSV_MAPPING = {
    'Recipient_Name'                => :organization,
    'Recipient_Phone'               => :contact_phone,
    'Notification'                  => nil,
    'Recipient_Notes'               => :notes,
    'Address_Line1'                 => :address_street,
    'Address_Line2'                 => :address_apartment,
    'City/Town'                     => :address_city,
    'Postal_Code'                   => :address_zip,
    'State/Province'                => :address_state,
    'Country'                       => :address_country,
    'Latitude'                      => :latitude,
    'Longitude'                     => :longitude,
    'Task_Details'                  => nil,
    'Pickup'                        => false,
    'completeAfter'                 => nil,
    'completeBefore'                => nil,
    'Organization'                  => nil,
    'Driver'                        => nil,
    'Team'                          => nil,
    'Quantity'                      => nil,
    'Merchant'                      => nil,
    'ServiceTime'                   => nil,
  }.freeze

  def public_attributes
    {
      organization: organization,
      address: address,
      latitude: latitude,
      longitude: longitude
    }
  end

  def self.fetch_all
    results = GetMePpe::Spreadsheets.hospitals
    headers = results.values[0]
    indexes = HEADER_VALUES.keys.each_with_object({}) do |k, obj|
      unless obj[k] = headers.index { |a| a == HEADER_VALUES.fetch(k) }
        raise "No index in #{headers} for #{HEADER_VALUES.fetch(k)}"
      end
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
        hospital.save if hospital.changed?
      end
    end
  end

  def valid_for_csv?
    address_street.present?
  end

  private

  def address_country
    'USA'
  end

  def set_address
    result = Geocoder.search(address).first
    return true unless result

    self.address_street = "#{result.house_number} #{result.street}"
    self.address_city = result.city
    self.address_zip = result.postal_code
    self.address_state = result.state
    self.address = "#{address_street}, #{address_city}, #{address_state} #{address_zip}"
    true
  end

end
