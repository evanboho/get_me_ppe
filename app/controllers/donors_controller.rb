class DonorsController < ApplicationController

  # GET
  def index
    @donors = Donor.order(number_of_masks: :desc)

    if status = params[:status].presence
      status = ['', nil] if status == 'blank'
      @donors = @donors.where(status: status)
    end
  end

  # GET
  def show
    @donor = Donor.find(params[:id])
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

  # POST
  def geocode
    donor = Donor.find(params[:id])
    if donor.geocode.nil?
      flash[:error] = 'Could not geocode donor'
    else
      donor.save
    end
    redirect_to donors_path
  end

  def onfleet_task
    donor = Donor.find(params[:id])
    unless @onfleet_task = donor.get_onfleet_task
      flash[:error] = 'Could not find Onfleet task for donor'
      redirect_to donors_path
    end
  end
end
