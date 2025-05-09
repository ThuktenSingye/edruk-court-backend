# frozen_string_literal: true

# Test Job
class TestJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Rails.logger.info "TestJob executed with args: #{args.inspect}"
  end
end
