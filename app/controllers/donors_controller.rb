class DonorsController < ApplicationController
  def index
    @donors = Donor.order(number_of_masks: :desc)

    if params[:status].present?
      @donors = @donors.where(status: params[:status])
    end
  end

  def sync_to_onfleet
    donor = Donor.find params[:id]
    begin
      donor.sync_onfleet_task
    rescue => e
      matcher = e.message.match(/\"message\"=>\"(?<message>.*)\", \"cause\"=>\"(?<cause>.*)\", \"request\"/)
      message = matcher[:message]
      cause = matcher[:cause]
      flash[:error] = "Error syncing to Onfleet: #{message} #{cause}"
    end
    redirect_to donors_path
  end

  def onfleet_task
    render json: Donor.find(params[:id]).get_onfleet_task
  end
end
