class WelcomeController < ApplicationController
  skip_before_action :require_current_applicant, :correct_applicant
end
