module Api
  class HospitalsController < ApiController

    MODEL = Hospital

    def load_objects
      Hospital.all
    end

  end
end
