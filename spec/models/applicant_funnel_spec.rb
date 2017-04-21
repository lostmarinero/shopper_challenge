# spec/models/applicant_funnel_spec.rb
require 'rails_helper'
require 'spec_helper'

describe 'ApplicantFunnel', type: :model do
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

  let(:thu_october_1)  { Date.parse('2015-10-01') }
  let(:wed_october_7)  { Date.parse('2015-10-07') }
  let(:mon_october_12) { Date.parse('2015-10-12') }
  let(:fri_october_16) { Date.parse('2015-10-16') }

  def monday_before(input_date)
    input_date.beginning_of_week(:monday)
  end

  describe 'defaults' do
    it 'defaults the start_date to 4 weeks before the end date' do
      af = ApplicantFunnel.new(end_date: '2014-12-01')
      expect(af.valid?).to be(true)
      expect(af.start_date).to eq(Date.parse('2014-12-01') - 4.weeks)
    end
    it 'defaults the end_date to 4 weeks after the start date' do
      af = ApplicantFunnel.new(start_date: '2014-12-01')
      expect(af.valid?).to be(true)
      expect(af.end_date).to eq(Date.parse('2014-12-01') + 4.weeks)
    end
    it 'defaults no start_start date to 4 weeks ago, end_date to today' do
      af = ApplicantFunnel.new({})
      expect(af.valid?).to be(true)
      expect(af.start_date).to eq(Date.today - 4.weeks)
      expect(af.end_date).to eq(Date.today)
    end
    it 'sets a default start_date if string start_date is an empty string' do
      af = ApplicantFunnel.new(end_date: '2014-12-01', start_date: '')
      expect(af.valid?).to be(true)
      expect(af.start_date).to eq(Date.parse('2014-12-01') - 4.weeks)
    end
    it 'sets a default end_date if string end_date is an empty string' do
      af = ApplicantFunnel.new(start_date: '2014-12-01', end_date: '')
      expect(af.valid?).to be(true)
      expect(af.end_date).to eq(Date.parse('2014-12-01') + 4.weeks)
    end
  end

  describe '#valid?' do
    it 'requires the start date to be before or equal to the end date' do
      expect(
        ApplicantFunnel.new(start_date: '2014-12-01',
                            end_date: '2014-11-20').valid?
      ).to be(false)
    end
    it 'is valid with a start date before the end date' do
      expect(
        ApplicantFunnel.new(start_date: '2014-11-01',
                            end_date: '2014-12-01').valid?
      ).to be(true)
    end
    it 'is valid with an equal start and end date' do
      expect(
        ApplicantFunnel.new(start_date: '2014-12-01',
                            end_date: '2014-12-01').valid?
      ).to be(true)
    end
  end

  describe 'data_counts_by_week' do
    it 'counts number applied, quiz_started, quiz_completed,
        onboarding_requested, onboarding_completed, hired, and rejected' do
      start_date_string = (thu_october_1 - 2).to_s
      first_sunday      = (thu_october_1 + 3)
      end_date_string   = (wed_october_7 + 2).to_s

      data_count_week_key = "#{start_date_string}-#{first_sunday}"

      app_funnel = ApplicantFunnel.new(start_date: start_date_string,
                                       end_date: end_date_string)
      data_counts = app_funnel.data_counts_by_week

      expect(data_counts[data_count_week_key]['applied'])
        .to eq(26)

      expect(data_counts[data_count_week_key]).to eq(
        'applied' => 26,
        'quiz_started' => 31,
        'quiz_completed' => 18,
        'onboarding_completed' => 3,
        'onboarding_requested' => 13,
        'hired' => 7,
        'rejected' => 0
      )

      applicants = Applicant.where('DATE(created_at) = ?',
                                   thu_october_1)
      ['quiz_started', 'quiz_completed', 'onboarding_completed',
       'onboarding_requested', 'hired', 'rejected'].each do |attribute|
        expect(
          applicants.where(workflow_state: attribute).count
        ).to eq(data_counts[data_count_week_key][attribute])
      end
    end
    it 'separates the data by week' do
      start_date_string = (thu_october_1 - 2).to_s
      first_sunday      = (thu_october_1 + 3)
      end_date_string   = (wed_october_7 + 2).to_s

      data_count_week_key1 = "#{start_date_string}-#{first_sunday}"
      data_count_week_key2 = "#{first_sunday + 1}-#{end_date_string}"
      app_funnel = ApplicantFunnel.new(start_date: start_date_string,
                                       end_date: end_date_string)
      data_counts = app_funnel.data_counts_by_week

      expect(data_counts[data_count_week_key1]['applied'])
        .to eq(26)

      expect(data_counts[data_count_week_key2]['applied'])
        .to eq(30)

      group1_applicants = Applicant.where('DATE(created_at) = ?',
                                          thu_october_1)
                                   .where(workflow_state: 'quiz_started')
      group2_applicants = Applicant.where('DATE(created_at) = ?',
                                          wed_october_7)
                                   .where(workflow_state: 'quiz_started')

      expect(group1_applicants.length).to eq(
        data_counts[data_count_week_key1]['quiz_started']
      )
      expect(group2_applicants.length).to eq(
        data_counts[data_count_week_key2]['quiz_started']
      )
    end
    it 'returns data even for only one day' do
      app_funnel = ApplicantFunnel.new(start_date: thu_october_1.to_s,
                                       end_date: thu_october_1.to_s)
      same_date_key = "#{thu_october_1}-#{thu_october_1}"
      expect(app_funnel.data_counts_by_week[same_date_key]['applied'])
        .to eq(26)
    end
    it 'returns data for a time period less than week (same week)' do
      tuesday  = (thu_october_1 - 2)
      friday   = (thu_october_1 + 1)
      app_funnel = ApplicantFunnel.new(start_date: tuesday.to_s,
                                       end_date: friday.to_s)
      data_key = "#{tuesday}-#{friday}"
      expect(app_funnel.data_counts_by_week[data_key]['applied'])
        .to eq(26)
    end
    it 'returns data for a time period less than week (different weeks)' do
      tue_oct_13 = (wed_october_7 + 6)
      sun_oct_9  = (wed_october_7 + 4)
      app_funnel = ApplicantFunnel.new(start_date: wed_october_7.to_s,
                                       end_date: tue_oct_13.to_s)
      key1 = "#{wed_october_7}-#{sun_oct_9}"
      key2 = "#{sun_oct_9 + 1}-#{tue_oct_13}"

      expect(app_funnel.data_counts_by_week[key1]['applied'])
        .to eq(30)
      expect(app_funnel.data_counts_by_week[key2]['applied'])
        .to eq(18)
    end
    it 'will omit weeks that have no data' do
      app_funnel = ApplicantFunnel.new(start_date: '2015-12-01',
                                       end_date: '2015-12-30')
      expect(app_funnel.data_counts_by_week).to eq({})
    end
    it 'will return empty hash if incorrect dates given' do
      app_funnel = ApplicantFunnel.new(start_date: '2015-12-11',
                                       end_date: '2015-12-03')
      expect(app_funnel.data_counts_by_week).to eq({})
    end
  end
end
