class WelcomeController < ApplicationController
  def index
    redirect_to(new_applicant_path)
  end
end
