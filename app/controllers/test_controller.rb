# frozen_string_literal: true

# Api Test Controller
class TestController < ApplicationController
  def index
    render json: { message: 'Hello from controller', status: 200 }
  end
end
