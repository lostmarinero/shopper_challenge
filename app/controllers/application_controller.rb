class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_applicant, :logged_in?
  before_action :require_current_applicant, :correct_applicant

  def current_applicant
    @applicant ||= Applicant.find_by(email: session[:applicant_email])
  end

  def logged_in?
    current_applicant != nil
  end

  def require_current_applicant
    unless current_applicant
      flash[:error] = 'Unable to find applicant.'
      redirect_to new_applicant_path
    end
  end

  def correct_applicant
    applicant = Applicant.find(params[:id])
    redirect_to(new_applicant_path) unless applicant == current_applicant
  end
end
