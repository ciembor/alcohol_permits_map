namespace :grouping_audit do
  desc 'Write a deterministic grouping audit checklist for the latest report'
  task write: :environment do
    reported_at = if ENV['REPORTED_AT'].present?
      Time.zone.parse(ENV.fetch('REPORTED_AT'))
    else
      AlcoholLicense.maximum(:reported_at)
    end
    sample_size = ENV.fetch('SAMPLE_SIZE', '50').to_i
    output_path = Rails.root.join(ENV.fetch('OUTPUT', 'docs/audits/grupowanie_audyt.md'))

    licenses = AlcoholLicense
      .where(reported_at: reported_at)
      .includes(:business, :business_category, :license_category, :license_point_group, location: :transformed_location)
      .to_a

    groups = LicensePointGroup.where(reported_at: reported_at).to_a
    groups_by_id = groups.index_by(&:id)
    licenses_by_group_id = licenses.group_by(&:license_point_group_id)
    licenses_by_location_id = licenses.group_by { |license| license.location.transformed_location_id }

    merged_groups = groups
      .select { |group| Array(group.business_ids).uniq.size > 1 }
      .sort_by { |group| [display_address_for_group(licenses_by_group_id.fetch(group.id, [])), group.id] }

    merged_group_ids = merged_groups.map(&:id).to_set
    split_location_ids = licenses_by_location_id
      .select do |_location_id, location_licenses|
        location_licenses.map(&:business_id).uniq.size > 1 &&
          location_licenses.map(&:license_point_group_id).compact.none? { |group_id| merged_group_ids.include?(group_id) }
      end
      .keys
      .sort_by { |location_id| Digest::SHA256.hexdigest("grouping-audit-v1:#{reported_at.to_i}:#{location_id}") }
      .first(sample_size)

    lines = []
    lines << '# Audyt grupowania punktów sprzedaży'
    lines << ''
    lines << "Raport: `#{reported_at.strftime('%Y-%m-%d %H:%M:%S')}`."
    lines << ''
    lines << 'Zakres kontroli:'
    lines << "- wszystkie grupy, w których algorytm połączył więcej niż jeden `business_id`: #{merged_groups.size},"
    lines << "- losowa, deterministyczna próba adresów wielopodmiotowych bez scalenia podmiotów: #{split_location_ids.size} z #{licenses_by_location_id.count { |_id, rows| rows.map(&:business_id).uniq.size > 1 && rows.map(&:license_point_group_id).compact.none? { |group_id| merged_group_ids.include?(group_id) } }}."
    lines << ''
    lines << 'Legenda decyzji:'
    lines << '- `OK` - grupowanie wygląda poprawnie.'
    lines << '- `ZA DUŻO SCALONE` - algorytm połączył podmioty, które powinny być osobnymi punktami.'
    lines << '- `POWINNO BYĆ SCALONE` - algorytm zostawił osobno wpisy, które wyglądają na ten sam punkt/podmiot.'
    lines << '- `NIEPEWNE` - sam wykaz nie wystarcza do rozstrzygnięcia.'
    lines << ''
    lines << '## A. Grupy scalające więcej niż jeden podmiot'
    lines << ''

    merged_groups.each.with_index(1) do |group, index|
      group_licenses = licenses_by_group_id.fetch(group.id, [])
      lines.concat(render_merged_group(index, group, group_licenses))
    end

    lines << '## B. Próba adresów wielopodmiotowych bez scalenia'
    lines << ''

    split_location_ids.each.with_index(1) do |location_id, index|
      location_licenses = licenses_by_location_id.fetch(location_id)
      lines.concat(render_split_location(index, location_id, location_licenses, groups_by_id))
    end

    File.write(output_path, "#{lines.join("\n")}\n")
    puts "Wrote #{output_path}"
  end

  def display_address_for_group(licenses)
    transformed_location = licenses.first&.location&.transformed_location
    display_address(transformed_location)
  end

  def display_address(transformed_location)
    return 'brak adresu' unless transformed_location

    [
      transformed_location.address_1,
      transformed_location.building_number,
      ("lok. #{transformed_location.unit_number}" if transformed_location.unit_number.present?),
      ("dz. #{transformed_location.parcel_number}" if transformed_location.parcel_number.present?)
    ].compact.join(' ')
  end

  def normalized_units(licenses)
    licenses
      .map { |license| license.location.transformed_location&.unit_number }
      .compact
      .map(&:presence)
      .compact
      .uniq
      .sort
  end

  def source_addresses(licenses)
    licenses
      .map { |license| [license.location.address_1, license.location.address_2].compact.join(' ') }
      .map(&:presence)
      .compact
      .uniq
      .sort
  end

  def render_merged_group(index, group, licenses)
    lines = []
    lines << "### A#{index.to_s.rjust(3, '0')}. #{display_address_for_group(licenses)}"
    lines << ''
    lines << "- decyzja: [ ] OK  [ ] ZA DUŻO SCALONE  [ ] NIEPEWNE"
    lines << "- notatka:"
    lines << "- `license_point_group_id`: `#{group.id}`"
    lines << "- lokal po normalizacji: #{format_values(normalized_units(licenses))}"
    lines << "- zapisy źródłowe adresu/lokalu: #{format_values(source_addresses(licenses))}"
    lines << "- `business_id`: #{format_values(Array(group.business_ids).uniq.sort)}"
    lines << "- podobieństwo nazw: #{format('%.3f', group.similarity_floor.to_f)}"
    lines << "- zezwolenia w grupie: #{licenses.size}"
    lines << ''
    lines << 'Podmioty w scalonej grupie:'
    lines.concat(render_businesses(licenses).map { |line| "  #{line}" })
    lines << ''
    lines
  end

  def render_split_location(index, location_id, licenses, groups_by_id)
    transformed_location = licenses.first.location.transformed_location
    grouped = licenses.group_by(&:license_point_group_id).sort_by do |group_id, group_licenses|
      [groups_by_id[group_id]&.display_business_name || group_licenses.first.business.name, group_id.to_i]
    end

    lines = []
    lines << "### B#{index.to_s.rjust(3, '0')}. #{display_address(transformed_location)}"
    lines << ''
    lines << "- decyzja: [ ] OK  [ ] POWINNO BYĆ SCALONE  [ ] NIEPEWNE"
    lines << "- notatka:"
    lines << "- `transformed_location_id`: `#{location_id}`"
    lines << "- lokal po normalizacji: #{format_values(normalized_units(licenses))}"
    lines << "- zapisy źródłowe adresu/lokalu: #{format_values(source_addresses(licenses))}"
    lines << "- liczba podmiotów: #{licenses.map(&:business_id).uniq.size}"
    lines << "- liczba grup: #{grouped.size}"
    lines << ''
    lines << 'Grupy pod tym adresem:'
    grouped.each do |group_id, group_licenses|
      group = groups_by_id[group_id]
      lines << "- grupa `#{group_id}`: #{group&.display_business_name || group_licenses.first.business.name}"
      lines << "  - `business_id`: #{format_values(group_licenses.map(&:business_id).uniq.sort)}"
      lines << "  - lokal po normalizacji: #{format_values(normalized_units(group_licenses))}"
      lines << "  - zapisy źródłowe adresu/lokalu: #{format_values(source_addresses(group_licenses))}"
      lines.concat(render_businesses(group_licenses).map { |line| "  #{line}" })
    end
    lines << ''
    lines
  end

  def render_businesses(licenses)
    licenses
      .group_by(&:business_id)
      .sort_by { |_business_id, business_licenses| business_licenses.first.business.name }
      .map do |business_id, business_licenses|
        categories = business_licenses
          .map { |license| "#{license.business_category.name} #{license.license_category.name}" }
          .uniq
          .sort
          .join(', ')
        source = format_values(source_addresses(business_licenses))
        "- `#{business_id}` #{business_licenses.first.business.name} (#{business_licenses.size} zez.; #{categories}; źródło: #{source})"
      end
  end

  def format_values(values)
    values = Array(values).compact.map(&:to_s).reject(&:blank?)
    return 'brak' if values.empty?

    values.map { |value| "`#{value}`" }.join(', ')
  end
end
