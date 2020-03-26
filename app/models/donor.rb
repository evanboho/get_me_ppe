require 'concerns/csv_helper'
require 'concerns/has_valid_phone_number'

class Donor < ApplicationRecord

  extend CsvHelper
  include HasValidPhoneNumber

  geocoded_by :address
  after_validation :geocode, if: -> { address_street_changed? }

  HEADER_VALUES = {
    name:                       'Name',
    status:                     'ADMIN: Status',
    number_of_masks:            'APPROX. HOW MANY UNUSED MASKS ARE YOU ABLE TO DONATE?',
    mask_condition:             'WHAT IS THE CONDITION OF THE MASKS?',
    email_address:              'Email address',
    phone_number:               'Phone number',
    address_street:             'PICKUP LOCATION (STREET NAME AND NUMBER; E.G 123 FAKE STREET)',
    address_apartment:          'PICKUP LOCATION (APARTMENT/UNIT)',
    address_city:               'PICKUP LOCATION (CITY)',
    address_zip:                'PICKUP LOCATION (ZIP CODE)',
    region:                     'Region',
  }.freeze

  CSV_MAPPING = {
    'Recipient_Name'                => :name,
    'Recipient_Phone'               => :phone_number,
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
    'Pickup'                        => true,
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
    %i(
      name
      email_address
      phone_number
      address_street
      address_apartment
      address_city
      latitude
      longitude
      status
    ).each_with_object({}) do |field, obj|
      obj[field] = self.send(field)
    end
  end

  def address
    "#{address_street}, #{address_city}, #{address_city}, #{address_zip}"
  end

  def self.fetch_all
    results = GetMePpe::Spreadsheets.donor_responses_internal_master

    headers = results.values[0].map(&:upcase)
    indexes = HEADER_VALUES.keys.each_with_object({}) do |k, obj|
      unless obj[k] = headers.index { |a| a == HEADER_VALUES.fetch(k).upcase }
        raise "No index in #{headers} for #{HEADER_VALUES.fetch(k)}"
      end
    end

    results.values[1..-1].map do |result|
      name = result[indexes[:name]]
      next unless name.present?

      args = HEADER_VALUES.keys.each_with_object({}) do |k, obj|
        obj[k] = result[indexes.fetch(k)]
      end

      find_or_initialize_by(name: name).tap do |donor|
        args.each do |k, v|
          donor.send("#{k}=", v)
        end
        donor.save
      end
    end
  end

  def valid_for_csv?
    address_street.present? && valid_phone_number?
  end

  def notes
    "#{number_of_masks} #{mask_condition}"
  end

  def address_state
    'California'
  end

  def address_country
    'USA'
  end

end
