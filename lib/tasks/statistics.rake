namespace :app do
  namespace :statistics do
    desc "Generate statistic reports"
    task :generate => :environment do
      Delayed::Job.enqueue Jobs::Statistic::GeneratePayments.new
      Delayed::Job.enqueue Jobs::Statistic::GenerateRetention.new
      Delayed::Job.enqueue Jobs::Statistic::GenerateSociality.new
    end
  end
end
