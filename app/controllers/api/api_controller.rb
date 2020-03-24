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
          render json: objects.map(&:public_attributes)
        }
        format.csv {
          send_data self.class::MODEL.to_csv(objects),
                    filename: "#{self.class::MODEL.name.downcase.pluralize}.csv",
                    type: 'text/csv'
        }
      end
    end

    private

    def set_default_format_to_json
      request.format = :json unless params[:format]
    end

  end
end
