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
      render json: self.class::MODEL.fetch_all(key: key)
    end

    private

    def set_default_format_to_json
      request.format = :json unless params[:format]
    end

  end
end
