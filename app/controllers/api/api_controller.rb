module Api
  class ApiController < ApplicationController

    before_action do
      request.format = :json unless params[:format]
    end

  end
end
