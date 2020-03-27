require 'lock_manager'

module Api
  class ApiController < ApplicationController

    before_action :set_default_format_to_json

    def index
      if params[:refresh] == 'true'
        self.class::MODEL.fetch_all
      end

      objects = load_objects

      respond_to do |format|
        format.json {
          if params[:to_onfleet]
            json = objects.map(&:to_onfleet_json)
          else
            json = objects.map(&:public_attributes)
          end
          render json: json
        }
        format.csv {
          send_data self.class::MODEL.to_csv(objects),
                    filename: "#{self.class::MODEL.name.downcase.pluralize}.csv",
                    type: 'text/csv'
        }
      end
    end

    def sync
      json = LockManager.with_lock("#{self.class::MODEL.name}#sync", timeout: 0) do
        self.class::MODEL.fetch_all(key: params[:key], range: params[:range])
      end
      render json: json
    rescue => e
      render json: { error: e }
    end

    def sync_to_onfleet
      donor = Donor.find(params[:id])
      donor.sync_to_onfleet
    end

    private

    def set_default_format_to_json
      request.format = :json unless params[:format]
    end

  end
end
