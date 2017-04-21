# spec/apis/funnels_endpoint_spec.rb
require 'rails_helper'
require 'spec_helper'

describe 'Funnels API', type: :request do
  before(:all) do
    Rails.application.load_seed
    Applicant.all[0..97].each do |applicant|
      # Thursday, October 1, 2015
      applicant.update(created_at: Date.parse('2015-10-01'))
    end
    Applicant.all[98..199].each do |applicant|
      # Wednesday, October 7, 2015
      applicant.update(created_at: Date.parse('2015-10-07'))
    end
    Applicant.all[200..249].each do |applicant|
      # Monday, October 12, 2015
      applicant.update(created_at:  Date.parse('2015-10-12'))
    end
    Applicant.all[250..299].each do |applicant|
      # Friday, October 16, 2015
      applicant.update(created_at:  Date.parse('2015-10-16'))
    end
  end
  after(:all) do
    DatabaseCleaner.clean_with(:truncation)
  end

  # Thursday, October 1, 2015
  let(:thu_october_1)  { Date.parse('2015-10-01') }
  # Wednesday, October 7, 2015
  let(:wed_october_7)  { Date.parse('2015-10-07') }
  # Monday, October 12, 2015
  let(:mon_october_12) { Date.parse('2015-10-12') }
  # Friday, October 16, 2015
  let(:fri_october_16) { Date.parse('2015-10-16') }

  describe 'validations' do
    it 'requires the start date to be before the end_date' do
      get '/funnels.json', start_date: '2014-12-01', end_date: '2014-11-28'

      json = JSON.parse(response.body)

      expect(response.status).to eq(400)
      expect(json['error']).to eq('Invalid start or end date')
    end
    it 'allows for the same start and end date' do
      get '/funnels.json', start_date: '2015-10-01', end_date: '2015-10-01'

      json = JSON.parse(response.body)

      expect(response.status).to eq(200)
      expect(json['2015-10-01-2015-10-01']['applied']).to eq(26)
    end

    it 'defaults a missing start_date to 4 weeks before end date' do
      Applicant.last.update(created_at: 4.weeks.ago.to_date - 1)

      get '/funnels.json', end_date: Date.yesterday.to_s

      end_of_first_week_date = (4.weeks.ago.to_date - 1).end_of_week(:monday)
      date_key = (
        (4.weeks.ago.to_date - 1).to_date.to_s +
        '-' + end_of_first_week_date.to_date.to_s
      )

      json = JSON.parse(response.body)

      expect(response.status).to eq(200)
      expect(json[date_key]['applied']).to eq(1)
    end
    it 'defaults missing end_date to 4 weeks after start_date' do
      Applicant.last.update(created_at: 12.days.ago)

      get '/funnels.json', start_date: 40.days.ago.to_date.to_s

      beginning_of_final_week_date =
        12.days.ago.beginning_of_week(:monday).to_date
      date_key = (
        beginning_of_final_week_date.to_s + '-' + 12.days.ago.to_date.to_s
      )

      json = JSON.parse(response.body)

      expect(response.status).to eq(200)
      expect(json[date_key]['applied']).to eq(1)
    end
    it 'defaults missing end_date to today if start_date less than 4 weeks' do
      Applicant.last.update(created_at: Date.today)

      get '/funnels.json', start_date: 20.days.ago.to_date.to_s

      beginning_of_final_week_date = Date.today.beginning_of_week(:monday)
      date_key = (beginning_of_final_week_date.to_s + '-' + Date.today.to_s)

      json = JSON.parse(response.body)

      expect(response.status).to eq(200)
      expect(json[date_key]['applied']).to eq(1)
    end
  end
  describe 'valid get requests' do
    it 'responds with a json object with date range keys' do
      # Wednesday, September 30, 2015
      start_date = '2015-09-30'
      # Sunday, October 18, 2015
      end_date   = '2015-10-18'

      first_key  = '2015-09-30-2015-10-04'
      middle_key = '2015-10-05-2015-10-11'
      last_key   = '2015-10-12-2015-10-18'

      get '/funnels.json', start_date: start_date, end_date: end_date

      json = JSON.parse(response.body)

      expect(response.status).to eq(200)
      expect(json[first_key]['applied']).to eq(26)
      expect(json[middle_key]['applied']).to eq(30)
      expect(json[last_key]['applied']).to eq(33)
    end
  end
end


  # def week_dates_keys(start_date, end_date)
  #   return ["#{start_date}-#{end_date}"] if end_date <= start_date + 6

  #   first_sunday = start_date.end_of_week(:monday)
  #   first_monday = first_sunday + 1
  #   keys = [[start_date, first_sunday]]

  #   until (first_monday + 6) >= end_date
  #     keys << [first_monday, (first_monday + 6)]
  #     first_monday += 6
  #   end

  #   keys << [first_monday, end_date]
  #   keys.map { |dates| "#{dates[0]}-#{dates[1]}" }
  # end
