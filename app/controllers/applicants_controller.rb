class ApplicantsController < ApplicationController
  skip_before_action :require_current_applicant, only: [:new, :create], raise: false
  skip_before_action :correct_applicant, only: [:new, :create], raise: false

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
    applicant = current_applicant

    # If update is from the consent form, get the consent params
    # otherwise update the other params
    update_params = if params[:applicant].keys
                                         .include?('background_check_consent')
                      applicant_consent_params
                    else
                      applicant_params
                    end

    if applicant.update(update_params)
      flash[:notice] = 'Success!'
      redirect_to applicant_path(applicant)
    else
      flash[:error] = 'There was an error updating your application :/'
      render 'edit'
    end
  end

  def show
    @applicant = Applicant.find(params[:id])
  end

  def edit
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

  def applicant_consent_params
    params.require(:applicant).permit(:background_check_consent)
  end
end
