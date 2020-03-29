class DonorsController < ApplicationController

  before_action :authenticate_user!

  # GET
  def index
    @donors = Donor.order('(case when latitude is null then 1 else 0 end) asc, number_of_masks desc')
    # @donors = Donor.order('number_of_masks desc')

    if status = params[:status].presence
      status = ['', nil] if status == 'blank'
      @donors = @donors.where(status: status)
    end
  end

  # GET
  def show
    @donor = Donor.find(params[:id])
  end

  def update
    @donor = Donor.find(params[:id])
    @donor.update(donor_params)
    redirect_to donor_path(@donor)
  end

  # POST
  def sync_to_onfleet
    donor = Donor.find params[:id]
    begin
      donor.sync_onfleet_task
    rescue Onfleet::AuthenticationError => e
      flash[:error] = 'API Key not set'
    rescue => e
      message_matcher = e.message.match(/\"message\"=>\"(?<message>.*)\"/)
      message = message_matcher && message_matcher[:message]
      cause_matcher = e.message.match(/\"cause\"=>\"(?<message>.*)\"/)
      cause = cause_matcher && cause_matcher[:cause]
      flash[:error] = "Error syncing to Onfleet: #{[message, cause].compact.join(' ')}"
    end
    redirect_to donors_path
  end

  # POST
  def geocode
    donor = Donor.find(params[:id])
    if donor.geocode.nil?
      flash[:error] = 'Could not geocode donor'
      redirect_to manual_geocode_donor_path(donor)
    else
      donor.save
      redirect_to donors_path
    end
  end

  # GET
  def manual_geocode
    @donor = Donor.find(params[:id])
  end

  def onfleet_task
    donor = Donor.find(params[:id])
    unless @onfleet_task = donor.get_onfleet_task
      flash[:error] = 'Could not find Onfleet task for donor'
      redirect_to donors_path
    end
  end

  private

  def donor_params
    params.require(:donor).permit(
      :address_street,
      :address_apartment,
      :address_city,
      :address_zip,
      :address_state,
      :latitude,
      :longitude
    )
  end
end
