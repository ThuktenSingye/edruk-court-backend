# frozen_string_literal: true

module Api
  module V1
    module Admin
      # Court Controller for Admin
      class CourtsController < BaseController
        before_action :court, only: %i[show update]

        def index
          @courts = Court.all
          authorize @courts
          render_json :ok, nil, serialized_courts(@courts)
        end

        def show
          authorize @court
          render_json :ok, nil, serialized_court(@court)
        end

        def create
          @court = Court.build(court_params)
          authorize @court
          if @court.save
            render_json :created, 'Court Created Successfully', serialized_court(@court)
          else
            render_json :unprocessable_entity, 'Failed to create court', @court.errors
          end
        end

        def update
          authorize @court
          if @court.update(court_params)
            render_json :ok, 'Court updated Successfully', serialized_court(@court)
          else
            render_json :unprocessable_entity, 'Failed to update court', @court.errors
          end
        end

        def statistics
          authorize :court, :statistics?
          @court_data = CourtStatisticSerializer.new(court_counts_by_type).serializable_hash[:data][:attributes]
          render_json :ok, nil, @court_data
        end

        private

        def court_counts_by_type
          {
            supreme_court: court_type('supreme'),
            high_court: court_type('high'),
            dzongkhag_court: court_type('dzongkhag'),
            dungkhag_court: court_type('dungkhag'),
            bench: court_type('bench')
          }
        end

        def court_type(type)
          Court.where(court_type: type).count
        end

        def court
          @court ||= Court.find(params[:id])
        end

        def serialized_courts(courts)
          courts.map do |court|
            CourtSerializer.new(court).serializable_hash[:data][:attributes]
          end
        end

        def serialized_court(court)
          CourtSerializer.new(court).serializable_hash[:data][:attributes]
        end

        def court_params
          params.expect(court: %i[name court_type email contact_no subdomain domain parent_court_id])
        end
      end
    end
  end
end
