class CsvController < ApplicationController

  def create
    if params[:type] == 'hospitals'

    elsif params[:type] == 'donors'
      send_data Donor.to_csv(Donor.where(status: '')),
                filename: 'donors.csv',
                type: 'text/csv'
    else
      raise 'Invalid type'
    end
  end

end
