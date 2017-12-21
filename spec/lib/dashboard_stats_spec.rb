require 'spec_helper'

RSpec.describe DashboardStats, type: :model do
  
  let(:hub1) { Fabricate(:homerton_hub) }
  let(:hub2) { Fabricate(:hub) }
  let(:advisor) { Fabricate(:advisor, hub: hub1) }
  let(:advisor2) { Fabricate(:advisor, hub: hub1) }
  
  before do
    Fabricate.times(1, :client, advisor: advisor)
    Fabricate.times(1, :client, advisor: advisor2)
    Fabricate.times(2, :client, advisor: Fabricate(:advisor, hub: hub2))
    Fabricate.times(3, :client,
                    advisor: Fabricate(:advisor, hub: hub1),
                    created_at: 1.month.ago)
    Fabricate.times(4, :client,
                    advisor: Fabricate(:advisor, hub: hub2),
                    created_at: 1.month.ago)
  end
  
  let(:from_date) { Time.zone.now.beginning_of_month }
  let(:to_date) { Time.zone.now.end_of_month }
  let(:options) { {} }
  let(:subject) { described_class.new(from_date, to_date, options) }
  
  it 'gets a registered count' do
    expect(subject.registered).to eq(4)
  end

  context 'with hub set' do
    
    let(:options) { { hub: hub1.id } }

    it 'gets a registered count' do
      expect(subject.registered).to eq(2)
    end
    
  end
  
  context 'with advisor set' do
    
    let(:options) { { advisor: advisor.id } }

    it 'gets a registered count' do
      expect(subject.registered).to eq(1)
    end
    
  end
  
  context 'with funding code set' do
          
    let(:options) { { funding_code: 'supported_employment' } }

    it 'gets the correct count' do
      Fabricate.times(3, :client, funded: %w[troubled_families supported_employment])
      Fabricate.times(2, :client, funded: %w[troubled_families])
      expect(subject.registered).to eq(3)
    end
    
  end
  
  context 'with month set' do
    
    let(:from_date) { 1.month.ago.beginning_of_month }
    let(:to_date) { 1.month.ago.end_of_month }
        
    it 'gets a registered count' do
      expect(subject.registered).to eq(7)
    end
    
    context 'with hub set' do
      
      let(:options) { { hub: hub1.id } }
      
      it 'gets a registered count' do
        expect(subject.registered).to eq(3)
      end
      
    end
        
  end
  
  context 'outcomes' do
    
    let!(:job_start_clients) do
      Fabricate.times(4, :client) do
        action_plan_tasks do
          [
            Fabricate(:action_plan_task,
                      outcome: 'job_apprenticeship',
                      status: 'completed',
                      ended_at: rand(Time.zone.now.beginning_of_month..Time.zone.now.end_of_month))
          ]
        end
      end
    end
    
    it 'gets client count for an outcome' do
      expect(subject.with_outcome('job_apprenticeship')).to eq(4)
    end
    
  end
  
end
