class ApplicantsController < ApplicationController
  before_action :require_current_applicant, :correct_applicant,
                only: [:update, :show, :edit], raise: false

  def new
    @applicant = Applicant.new
  end

  def create
    new_applicant_params = applicant_params.merge(workflow_state: 'applied')
    @applicant = Applicant.new(new_applicant_params)
    if @applicant.save
      set_current_applicant(@applicant)
      redirect_to @applicant, notice: 'Application successfully created!'
    else
      flash[:error] = @applicant.errors.full_messages
      render 'new'
    end
  end

  def update
    @applicant = current_applicant

    # If update is from the consent form, get the consent params
    # otherwise update the other params
    update_params = if params[:applicant].keys
                                         .include?('background_check_consent')
                      applicant_consent_params
                    else
                      applicant_params
                    end

    if @applicant.update(update_params)
      set_current_applicant(@applicant)
      flash[:notice] = 'Success!'
      redirect_to applicant_path(@applicant)
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

  def login
    if logged_in?
      redirect_to applicant_path(current_applicant)
    end
    @applicant = Applicant.new
  end

  def create_session
    @applicant = Applicant.find_by(email: applicant_email_params[:email])
    if @applicant
      set_current_applicant(@applicant)
      redirect_to applicant_path(@applicant)
    else
      flash[:error] = 'Unable to find applicant with that email'
      redirect_to root_path
    end
  end

  def end_session
    remove_current_applicant
    redirect_to root_path
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

  def applicant_email_params
    # strong params to ensure we whitelist inputs fields allowed
    params.require(:applicant).permit(:email)
  end

  def applicant_consent_params
    params.require(:applicant).permit(:background_check_consent)
  end
end
