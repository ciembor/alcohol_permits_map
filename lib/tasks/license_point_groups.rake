namespace :license_point_groups do
  desc 'Rebuild persisted license point groups for one report or all reports'
  task rebuild: :environment do
    reports = if ENV['REPORT_AT'].present?
                [AlcoholLicense.where(reported_at: Time.zone.parse(ENV.fetch('REPORT_AT')).utc).pick(:reported_at)]
              elsif ENV['ALL'] == '1'
                AlcoholLicense.where.not(reported_at: nil).distinct.order(:reported_at).pluck(:reported_at)
              else
                [AlcoholLicense.maximum(:reported_at)]
              end.compact

    reports.each do |reported_at|
      count = LicensePointGroupBuilder.rebuild!(reported_at: reported_at)
      puts "#{reported_at.iso8601}: #{count} groups"
    end
  end
end
