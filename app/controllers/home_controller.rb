class HomeController < ApplicationController

  before_action :authenticate_user!

  def index
    if params[:refresh]
      @hospitals = Hospital.fetch_all
      @donors = Donor.fetch_all
    else
      @hospitals = Hospital.all.to_a
      @donors = Donor.all.to_a
    end
  end
end
