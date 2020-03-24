module Api
  class DonorsController < Api::ApiController

    MODEL = Donor

    def load_objects
      status = params[:status] || ''
      if status == 'any'
        return Donor.all
      else
        return Donor.where(status: status)
      end
    end

  end
end
