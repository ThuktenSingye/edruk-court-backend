# frozen_string_literal: true

module Users
  module Cases
    # Case Services
    class CaseService
      def initialize(case_params, current_user)
        @case_params = case_params
        @current_user = current_user
        @defendants_attrs = @case_params.delete(:defendants_attributes) || {}
      end

      def build_case
        @case = ::Case.new(@case_params)
        add_plaintiff
        add_defendants
        @case
      end

      private

      def add_plaintiff
        plaintiff_role = Role.find_by!(name: 'Plaintiff')
        @case.case_participants.build(user: @current_user, role_id: plaintiff_role.id)
      rescue ActiveRecord::RecordNotFound
        raise "Required 'Plaintiff' role not found in database"
      end

      def add_defendants
        defendant_role = Role.find_by!(name: 'Defendant')
        process_addresses(@defendants_attrs)
        @case.case_participants.build(
          @defendants_attrs.merge(role_id: defendant_role.id)
        )
      rescue ActiveRecord::RecordNotFound
        raise "Required 'Defendant' role not found in database"
      end

      def process_addresses(defendant_attrs)
        addresses = defendant_attrs.delete(:addresses_attributes) || {}

        address_data = addresses.values.map do |addr|
          addr.except(:id, :_destroy)
        end

        defendant_attrs[:address_data] = address_data
      end
    end
  end
end
