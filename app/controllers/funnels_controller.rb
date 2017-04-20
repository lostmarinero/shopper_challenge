class FunnelsController < ApplicationController
  def index
    applicant_funnel = ApplicantFunnel.new(ind_funnel_params)
    unless applicant_funnel.valid?
      respond_to do |format|
        response_message = { error: 'Invalid start or end date' }
        format.html do
          render 'error', locals: { message: response_message }, status: 400
        end
        format.json do
          render json: response_message, status: 400
        end
      end
      return
    end

    @funnel = applicant_funnel.data_counts_by_week

    respond_to do |format|
      format.html do
        @chart_funnel = formatted_funnel
        @start_end_params = ind_funnel_params
      end
      format.json { render json: @funnel }
    end
  end

  private

  def funnel_params
    params.permit(:start_date, :end_date, :format)
  end

  # generates a formatted version of the funnel for display in d3
  def formatted_funnel
    formatted = Hash.new { |h, k| h[k] = [] }

    @funnel.each do |date, state_counts|
      state_counts.each do |state, count|
        formatted[state] << {label: date, value: count}
      end
    end

    formatted.map do |k, v|
      {
        key: k.humanize,
        values: v
      }
    end
  end
end
