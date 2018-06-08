class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  def not_found
    raise ActiveRecord::RecordNotFound, "Not Found"
    rescue StandardError
      render_404
  end

  private
  def render_404
    render file: "#{Rails.root}/public/404", status: :not_found
  end
end
