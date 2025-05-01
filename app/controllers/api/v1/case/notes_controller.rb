# frozen_string_literal: true

module Api
  module V1
    module Case
      # Notes Controller
      class NotesController < ApplicationController
        before_action :authenticate_user!
        before_action :court_cases
        before_action :case
        before_action :hearing
        before_action :note, only: %i[update destroy]

        def index
          @notes = policy_scope(@hearing.notes.order(created_at: :desc).limit(10))
          authorize @notes
          render_json :ok, nil, serialized_notes(@notes)
        end

        def create
          @note = @hearing.notes.build(note_params.merge(user: current_user))
          authorize @note
          if @note.save
            render_json :created, 'Note Created Successfully', serialized_note(@note)
          else
            render_json :unprocessable_entity, 'Failed to create note', @note.errors
          end
        end

        def update
          authorize @note
          if @note.update(note_params.merge(user: current_user))
            render_json :ok, 'Note Updated Successfully', serialized_note(@note)
          else
            render_json :unprocessable_entity, 'Failed to update note', @note.errors
          end
        end

        def destroy
          authorize @note
          if @note.destroy
            render_json :ok, 'Note Deleted Successfully', { id: @note.id }
          else
            render_json :unprocessable_entity, 'Failed to delete note', @note.errors
          end
        end

        private

        def court_cases
          @court_cases ||= ::Case
                           .where(court_id: current_user.accessible_court_ids)
                           .or(::Case.where(bench_id: current_user.accessible_court_ids))
        end

        def case
          @case ||= @court_cases.find_by(id: params[:case_id])
        end

        def hearing
          @hearing ||= @case.hearings.find(params[:hearing_id])
        end

        def note
          @note ||= @hearing.notes.find(params[:id])
        end

        def serialized_notes(notes)
          notes.map { |note| NoteSerializer.new(note).serializable_hash[:data][:attributes] }
        end

        def serialized_note(note)
          NoteSerializer.new(note).serializable_hash[:data][:attributes]
        end

        def note_params
          params.expect(note: [:content])
        end
      end
    end
  end
end
