module Api
  class OnfleetWebhookRequestsController < Api::ApiController
    skip_before_action :verify_authenticity_token

    def index
      if params[:check]
        render plain: params[:check]
      else
        render json: OnfleetWebhookRequest.all.map(&:body)
      end
    end

    def create
      request_body = request.body.read
      OnfleetWebhookRequest.create(body: JSON.parse(request_body))
      render json: request_body
    rescue => e
      render json: { succes: false, error: { class: e.class.name, message: e.message } }
    end

  end
end
