# frozen_string_literal: true

module Hearings
  # Hearing Service Class
  class HearingService
    attr_reader :hearing_params

    delegate :current_tenant, to: :ActsAsTenant

    def initialize(court_case, hearing, hearing_params, current_user)
      @case = court_case
      @hearing = hearing
      @hearing_params = hearing_params
      @current_user = current_user
    end

    def create_and_notify
      hearing_type
    end

    def notify_on_update
      Hearings::HearingNotificationService.new(@case, @hearing).notify_case_participant('hearing_update', @current_user)
    end

    private

    def hearing_type
      return unless @hearing.hearing_type

      case @hearing.hearing_type.name.downcase
      when 'miscellaneous'
        create_miscellaneous_hearing
      when 'preliminary'
        create_preliminary_hearing
      else
        notify_post_hearing
      end
    end

    def notify_post_hearing
      judge = current_tenant.users.with_role(:Judge).first
      notify_user(judge)
    end

    def create_miscellaneous_hearing
      if bench_exist?
        assign_to_bench('miscellaneous')
      else
        default_assignment
      end
    end

    def create_preliminary_hearing
      if bench_exist?
        assign_to_bench('preliminary')
      else
        default_assignment
      end
    end

    def assign_to_bench(hearing_type)
      bench = current_tenant.child_courts.find_by(id: @hearing_params[:bench_id])
      @case.bench_id = bench.id if bench.present?
      @case.update(case_status: :active)
      @case.save
      assign_to_bench_judge(bench)
      assign_to_bench_clerk(bench) if hearing_type == 'preliminary'
    end

    def default_assignment
      @case.court = current_tenant
      assign_to_judge
    end

    def assign_to_bench_clerk(bench)
      clerk = bench.users.with_role(:Clerk).find_by(id: @hearing_params[:clerk_id])

      assign_clerk_to_case(clerk)
    end

    def assign_to_clerk
      clerk = current_tenant.users.with_role(:Clerk).find_by(id: @hearing_params[:clerk_id])

      assign_clerk_to_case(clerk)

      notify_user(clerk)
    end

    def assign_to_judge
      judge = find_judge
      assign_judge_to_case(judge)
    end

    def assign_to_bench_judge(bench)
      judge = find_bench_judge(bench)
      assign_judge_to_case(judge)
    end

    def assign_judge_to_case(judge)
      return unless judge&.has_role?(:Judge)

      @case.case_participants.find_or_create_by!(user: judge, role: Role.find_by(name: 'Judge'))

      notify_user(judge)
    end

    def assign_clerk_to_case(clerk)
      return unless clerk&.has_role?(:Clerk)

      @case.case_participants.find_or_create_by!(user: clerk, role: Role.find_by(name: 'Clerk'))
    end

    def notify_user(user)
      Hearings::HearingNotificationService.new(@case, @hearing).notify_user(user)
    end

    def find_bench_judge(bench)
      return unless bench

      bench.users&.with_role(:Judge)&.find_by(id: @hearing_params[:judge_id])
    end

    def find_judge
      current_tenant.users.with_role(:Judge).first
    end

    def bench_exist?
      current_tenant.child_courts&.exists?(court_type: 'bench')
    end
  end
end
