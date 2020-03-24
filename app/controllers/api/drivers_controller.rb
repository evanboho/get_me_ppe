module Api
  class DriversController < ApiController

    # MODEL = Driver

    def load_objects
      Driver.all
    end

  end
end
