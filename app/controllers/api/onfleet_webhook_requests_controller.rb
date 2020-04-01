module Api
  class OnfleetWebhookRequestsController < Api::ApiController
    skip_before_action :verify_authenticity_token

    STATES = {
      'unassigned' => 0,
      'assigned'   => 1,
      'active'     => 2,
      'completed'  => 3
    }.freeze

    def index
      if params[:check]
        render plain: params[:check]
      else
        requests = OnfleetWebhookRequest.all.select do |request|
          found = true
          if params[:onfleet_task_id]
            found = request.body['taskId'] == params[:onfleet_task_id]
          end
          if params[:state]
            state = STATES.fetch(params[:state], params[:state])
            found = found && request.body.dig('data', 'task','state') == state
          end
          found
        end

        render json: requests.map(&:body)
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
