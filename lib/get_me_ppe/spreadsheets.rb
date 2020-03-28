module GetMePpe
  module Spreadsheets

    SHEET_MAP = {
      active_offers: {
        key: '1_j_491PKcHSZPFmyQCyBuks5RSmOKunbE823UkJ0Mww',
        range: 'A1:Z99'
      }.freeze,
      hospitals: {
        key: '1IHeI3IA6eLSlUUjpQXPPLufEOtAKfT0Spxv36fk3eVo',
        range: '1:1 Hospital outreach'
      }.freeze,
      drivers: {
        key: '1UYpr45GHUj_f2ozXh-68T-NndnDOgvG4ZvQtSj6DeUE',
        range: 'A1:Z99'
      }.freeze,
      donor_responses_internal_master: {
        key: nil,
        range: 'A1:Z999'
      }
    }.freeze

    class << self

      def active_offers
        GoogleSheets.spreadsheet(SHEET_MAP.fetch(:active_offers))
      end

      def hospitals
        GoogleSheets.spreadsheet(SHEET_MAP.fetch(:hospitals))
      end

      def donors
        GoogleSheets.spreadsheet(SHEET_MAP.fetch(:donors))
      end

      def donor_responses_internal_master(key: nil, range: nil)
        args = SHEET_MAP.fetch(:donor_responses_internal_master).dup
        args[:key] = key if key
        raise 'No key provided' if key.nil?
        args[:range] = range.upcase if range
        GoogleSheets.spreadsheet(args)
      end

    end
  end
end
