class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_applicant, :logged_in?,
                :set_current_applicant, :remove_current_applicant

  def current_applicant
    @applicant ||= Applicant.find_by(email: session[:applicant_email])
  end

  def logged_in?
    current_applicant != nil && current_applicant.id != nil
  end

  def set_current_applicant(applicant)
    session[:applicant_email] = applicant.email
  end

  def remove_current_applicant
    session[:applicant_email] = nil
  end

  def require_current_applicant
    unless current_applicant
      flash[:error] = 'Unable to find applicant.'
      redirect_to root_path
    end
  end

  def correct_applicant
    applicant = Applicant.find(params[:id])
    unless applicant == current_applicant
      flash[:error] = 'Unable to find applicant.'
      redirect_to(root_path)
    end
  end
end

# break
