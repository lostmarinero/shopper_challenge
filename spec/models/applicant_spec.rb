# spec/models/applicant_spec.rb
require 'rails_helper'
require 'spec_helper'

describe 'Applicant', type: :model do
  before(:all) do
    Rails.application.load_seed
    Applicant.all[0..55].each do |applicant|
      # Thursday, October 1, 2015
      applicant.update(created_at: Date.parse('2015-10-01'))
    end
    Applicant.all[56..97].each do |applicant|
      # Tuesday, October 6, 2015
      applicant.update(created_at: Date.parse('2015-10-06'))
    end
    Applicant.all[98..149].each do |applicant|
      # Wednesday, October 7, 2015
      applicant.update(created_at: Date.parse('2015-10-07'))
    end
    Applicant.all[150..199].each do |applicant|
      # Thursday, October 8, 2015
      applicant.update(created_at: Date.parse('2015-10-08'))
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
  let(:tue_october_6)  { Date.parse('2015-10-06') }
  let(:wed_october_7)  { Date.parse('2015-10-07') }
  let(:thu_october_8)  { Date.parse('2015-10-08') }
  let(:mon_october_12) { Date.parse('2015-10-12') }
  let(:fri_october_16) { Date.parse('2015-10-16') }

  describe '.count_by_workflow_state' do
    it 'requires a two date arguments' do
      expect { Applicant.count_by_workflow_state(thu_october_1, '') }
        .to raise_error(ArgumentError)
    end
    it 'requires a workflow_state argument (string)' do
      expect do
        Applicant.count_by_workflow_state(thu_october_1, thu_october_1)
      end.to raise_error(ArgumentError)
    end
    it 'the sum of all results equals the total number of applicants' do
      sum_of_applicants = %w[applied quiz_started quiz_completed
                             onboarding_requested onboarding_completed
                             hired rejected].reduce(0) do |sum, wf_state|
                               wf_total = Applicant.count_by_workflow_state(
                                 thu_october_1 - 1,
                                 fri_october_16 + 1,
                                 wf_state
                               )
                               wf_total + sum
                             end
      expect(sum_of_applicants).to eq(300)
    end
    it 'responds to a workflow_state of applied' do
      expect(Applicant.count_by_workflow_state(thu_october_1,
                                               wed_october_7,
                                               'applied')).to eq(40)
    end
    it 'responds to a workflow_state of quiz_started' do
      expect(Applicant.count_by_workflow_state(thu_october_1,
                                               wed_october_7,
                                               'quiz_started')).to eq(45)
    end
    it 'responds to a workflow_state of quiz_completed' do
      expect(Applicant.count_by_workflow_state(thu_october_1,
                                               wed_october_7,
                                               'quiz_completed')).to eq(32)
    end
    it 'responds to a workflow_state of onboarding_requested' do
      expect(
        Applicant.count_by_workflow_state(thu_october_1,
                                          wed_october_7,
                                          'onboarding_requested')
      ).to eq(19)
    end
    it 'responds to a workflow_state of onboarding_completed' do
      expect(
        Applicant.count_by_workflow_state(thu_october_1,
                                          wed_october_7,
                                          'onboarding_completed')
      ).to eq(7)
    end
    it 'responds to a workflow_state of hired' do
      expect(Applicant.count_by_workflow_state(thu_october_1,
                                               wed_october_7,
                                               'hired')).to eq(7)
    end
    it 'responds to a workflow_state of rejected' do
      expect(Applicant.count_by_workflow_state(thu_october_1,
                                               wed_october_7,
                                               'rejected')).to eq(0)
    end

    context 'with edge cases' do
      let(:oct_1_applied) do
        Applicant.where(created_at: thu_october_1,
                        workflow_state: 'applied').count
      end
      let(:oct_6_applied) do
        Applicant.where(created_at: tue_october_6,
                        workflow_state: 'applied').count
      end
      let(:oct_7_applied) do
        Applicant.where(created_at: wed_october_7,
                        workflow_state: 'applied').count
      end
      let(:oct_8_applied) do
        Applicant.where(created_at: thu_october_8,
                        workflow_state: 'applied').count
      end

      it 'returns the number zero if there are no applicants in the range' do
        expect(
          Applicant.count_by_workflow_state(10.days.ago, 1.day.ago, 'applied')
        ).to eq(0)
      end
      it 'includes applicants that applied on the end date' do
        total_applied = oct_1_applied + oct_6_applied + oct_7_applied
        expect(
          Applicant.count_by_workflow_state(thu_october_1,
                                            wed_october_7,
                                            'applied')
        ).to eq(40)
      end
      it 'includes applicants that applied on the start date' do
        expect(
          Applicant.count_by_workflow_state(mon_october_12,
                                            mon_october_12 + 1,
                                            'applied')
        ).to eq(18)
      end
      it 'can return the count when the start and end date are equal' do
        expect(
          Applicant.count_by_workflow_state(fri_october_16,
                                            fri_october_16,
                                            'applied')
        ).to eq(15)
      end
    end
  end
  describe '.get_week_data' do
    it 'requires a start_date and end_date' do
      expect { Applicant.get_week_data(thu_october_1) }
        .to raise_error(ArgumentError)
    end
    it 'returns all of the workflow_state attributes with the count' do
      expect(Applicant.get_week_data(thu_october_1, wed_october_7))
        .to eq('applied' => 40,
               'hired' => 7,
               'onboarding_completed' => 7,
               'onboarding_requested' => 19,
               'quiz_completed' => 32,
               'quiz_started' => 45,
               'rejected' => 0)
    end
  end
end
