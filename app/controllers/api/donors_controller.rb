module Api
  class DonorsController < ApiController

    def index
      status = params[:status] || ''
      if status == 'any'
        donors = Donor.all
      else
        donors = Donor.where(status: status)
      end

      respond_to do |format|
        format.json {
          render json: donors.map(&:public_attributes)
        }
        format.csv {
          send_data Donor.to_csv(donors),
                    filename: 'donors.csv',
                    type: 'text/csv'
        }
      end
    end

  end
end
