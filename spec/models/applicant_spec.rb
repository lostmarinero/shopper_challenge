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
end
