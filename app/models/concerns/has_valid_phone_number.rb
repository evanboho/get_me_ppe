module HasValidPhoneNumber
  extend ActiveSupport::Concern

  included do |*args|
    before_validation :clean_phone_number
  end

  def self.clean(number_str)
    return unless number_str
    cleaned_phone = number_str.scan(/\d/)
    if cleaned_phone.first == '1'
      cleaned_phone.shift
    end
    if cleaned_phone.length == 10
      cleaned_phone = [
        '+1',
        cleaned_phone[0..2].join(''),
        cleaned_phone[3..5].join(''),
        cleaned_phone[6..9].join(''),
      ].join('')
    else
      nil
    end
  end

  def clean_phone_number
    send("#{phone_field}=", HasValidPhoneNumber.clean(send(phone_field)))
    true
  end

  def valid_phone_number?
    send(phone_field).match(/^\(\d{3}\) \d{3}-\d{4}$/).present?
  end

  def phone_field
    @phone_field ||= self.class.column_names.find { |a| a =~ /phone/ }
  end

end
