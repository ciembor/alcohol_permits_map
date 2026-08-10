require 'json'
require 'net/http'
require 'uri'

module Sim
  class PopulationImporter
    ENDPOINT = 'https://msip.um.krakow.pl/arcgis/rest/services/Elud/Elud_Sim/MapServer/0/query'.freeze
    PAGE_SIZE = 2_000
    OUT_FIELDS = %w[nr_jed_sim nazwa_sim na_dzien_txt na_dzien_kod r_ogolem].freeze

    def self.import!
      new.import!
    end

    def import!
      imported = 0
      units_by_code = Sim::Units.by_code

      SimPopulation.transaction do
        each_remote_record do |attributes|
          unit_code = attributes.fetch('nr_jed_sim').to_s.strip
          unit = units_by_code.fetch(unit_code)

          population = SimPopulation.find_or_initialize_by(
            observed_on: Date.iso8601(attributes.fetch('na_dzien_txt')),
            sim_unit_code: unit_code
          )
          population.assign_attributes(
            observed_on_code: attributes.fetch('na_dzien_kod'),
            sim_unit_name: attributes.fetch('nazwa_sim'),
            district_code: unit.fetch(:district_code),
            district_name: unit.fetch(:district),
            total: attributes.fetch('r_ogolem')
          )
          population.save!
          imported += 1
        end
      end

      imported
    end

    private

    def each_remote_record
      offset = 0

      loop do
        page = fetch_page(offset)
        features = page.fetch('features')
        break if features.empty?

        features.each do |feature|
          yield feature.fetch('attributes')
        end

        break if features.size < PAGE_SIZE && !page['exceededTransferLimit']

        offset += PAGE_SIZE
      end
    end

    def fetch_page(offset)
      uri = URI(ENDPOINT)
      uri.query = URI.encode_www_form(
        f: 'json',
        where: '1=1',
        returnGeometry: 'false',
        outFields: OUT_FIELDS.join(','),
        orderByFields: 'na_dzien_kod,nr_jed_sim',
        resultOffset: offset,
        resultRecordCount: PAGE_SIZE
      )

      response = http_get(uri)
      raise "MSIP population import failed: HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body)
    end

    def http_get(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      http.open_timeout = 10
      http.read_timeout = 60
      http.request(Net::HTTP::Get.new(uri))
    end
  end
end
