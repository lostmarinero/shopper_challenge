class ApplicantsController < ApplicationController
  def new
    @applicant = Applicant.new
  end

  def create
    new_applicant_params = applicant_params.merge(workflow_state: 'applied')
    @applicant = Applicant.new(new_applicant_params)
    if @applicant.save
      session[:applicant_email] = @applicant.email
      redirect_to @applicant, notice: 'Application successfully created!'
    else
      flash[:error] = @applicant.errors.full_messages
      render 'new'
    end
  end

  def update
    # your code here
  end

  def show
    @applicant = Applicant.find(params[:id])
  end

  private

  def applicant_params
    # strong params to ensure we whitelist inputs fields allowed
    params.require(:applicant).permit(
      :first_name,
      :last_name,
      :email,
      :phone,
      :phone_type,
      :region
    )
  end
end
