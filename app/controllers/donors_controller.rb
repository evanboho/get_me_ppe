class DonorsController < ApplicationController

  # GET
  def index
    @donors = Donor.order(number_of_masks: :desc)

    if status = params[:status].presence
      status = ['', nil] if status == 'blank'
      @donors = @donors.where(status: status)
    end
  end

  # POST
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
