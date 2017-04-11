class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_applicant, :logged_in?

  def current_applicant
    @applicant ||= Applicant.find_by(email: session[:applicant_email])
  end

  def logged_in?
    current_applicant != nil
  end
end
