namespace :sim do
  desc 'Import historical permanent registration totals for SIM units from MSIP'
  task import_population: :environment do
    count = Sim::PopulationImporter.import!
    dates = SimPopulation.distinct.count(:observed_on)
    puts "Imported #{count} SIM population rows across #{dates} dates"
  end
end
