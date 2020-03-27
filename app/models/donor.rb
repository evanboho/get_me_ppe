require 'concerns/csv_helper'
require 'concerns/has_valid_phone_number'

Onfleet.api_key = ENV['ONFLEET_API_KEY']

class Donor < ApplicationRecord

  extend CsvHelper
  include HasValidPhoneNumber

  geocoded_by :address
  after_validation :geocode, if: -> { address_street_changed? }

  scope :unassigned, -> { where(status: ['', nil]) }
  scope :preferential_order, -> { order(number_of_masks: :desc) }

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
    other_ppe:                  'Do you have other PPE you can donate?',
    donor_comments:             'Is there anything else we should know?',
    items_for_pickup:           'Items for Pickup',
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

  ONFLEET_API_MAPPING = {
    recipients:      :recipients,
    destination:     :destination,
    pickup:          true,
    complete_after:  nil,
    complete_before: nil,
    quantity:        :quantity,
    metadata:        :metadata,
  }.freeze

  ONFLEET_STATES = {
    unassigned: 0,
    assigned: 1,
    active: 2,
    completed: 3,
  }.freeze

  def self.sync_to_onfleet
    # tasks = Onfleet::Task.list

  end

  def quantity

  end

  def get_task_from_onfleet
    Onfleet::Task.get(onfleet_task_id)
  end

  def create_in_onfleet
    task = Onfleet::Task.create to_onfleet_json
    self.onfleet_task_id = task.id
    self.save
  rescue => e
    puts "Error for Donor:#{id}. #{e}"
    nil
  end

  def to_onfleet_json
    ONFLEET_API_MAPPING.each_with_object({}) do |(k, v), obj|
      if v.is_a?(Symbol)
        obj[k] = self.send(v)
      else
        obj[k] = v
      end
    end
  end

  def metadata
    {
      number_masks: number_of_masks,
      mask_condition: mask_condition,
      gloves_count: gloves_count,
      other_ppe_count: other_ppe_count,
    }.each_with_object([]) do |(k, v), arr|
      arr << {
        name: k,
        value: v,
        type: v.is_a?(Integer) ? 'number' : 'string'
      }
    end
  end

  def longitude_latitude
    [longitude, latitude]
  end

  def destination
    {
      address: {
        number: address_street.scan(/\d/).join(''),
        street: address_street.scan(/[A-Z][a-z].*/).join(''),
        city: address_city,
        state: address_state,
        postalCode: address_zip,
        country: 'USA',
      },
      location: longitude_latitude,
    }
  end

  def recipients
    [
      {
        name: name,
        phone: phone_number,
        notes: notes
      }
    ]
  end

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
    [address_street, address_apartment, address_city, address_zip, 'USA'].map(&:presence).compact.join(', ')
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

  def items_for_pickup=(val)
    self.mask_count = val&.match(/(?<count>\d*) masks/)&.try(:[], :count).to_i
    self.gloves_count = val&.match(/(?<count>\d*) gloves/)&.try(:[], :count).to_i
    self.other_ppe_count = val&.match(/(?<count>\d*) Other PPE/)&.try(:[], :count).to_i
  end

  def valid_for_csv?
    address_street.present? && valid_phone_number?
  end

  def notes
    arr = ["#{number_of_masks} #{mask_condition}"]
    arr << ["#{gloves_count} gloves"] if gloves_count.to_i > 0
    arr << ["#{other_ppe_count} other PPE"] if other_ppe_count.to_i > 0
    arr.join(',')
  end

  def address_state
    'California'
  end

  def address_country
    'USA'
  end

end
