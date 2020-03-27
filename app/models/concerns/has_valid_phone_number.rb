module HasValidPhoneNumber
  extend ActiveSupport::Concern

  included do |*args|
    before_validation :clean_phone_number
  end

  def clean_phone_number
    clean_phone = send(phone_field).scan(/\d/)
    if clean_phone.first == '1'
      clean_phone.shift
    end
    if clean_phone.length == 10
      cleaned_phone = [
        '+1',
        clean_phone[0..2].join(''),
        clean_phone[3..5].join(''),
        clean_phone[6..9].join(''),
      ].join('')

      send("#{phone_field}=", cleaned_phone)
    end
    true
  end

  def valid_phone_number?
    send(phone_field).match(/^\(\d{3}\) \d{3}-\d{4}$/).present?
  end

  def phone_field
    @phone_field ||= self.class.column_names.find { |a| a =~ /phone/ }
  end

end
