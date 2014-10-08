namespace :dummy do
  desc "Seed users"
  task :seed => :environment do
    10.times do
      User.create
    end
  end
end
