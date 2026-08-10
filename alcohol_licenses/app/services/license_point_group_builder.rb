class LicensePointGroupBuilder
  SIMILARITY_THRESHOLD = 0.90
  BUSINESS_NAME_ALIASES = [
    %w[PAJDA KLESYK],
    %w[SCANDALE PAJDA KLESYK]
  ].map { |tokens| tokens.sort.join(' ') }.freeze

  def self.rebuild!(reported_at:)
    new(reported_at).rebuild!
  end

  def initialize(reported_at)
    @reported_at = reported_at
  end

  def rebuild!
    licenses = geocoded_licenses
    groups = build_groups(licenses)

    LicensePointGroup.transaction do
      AlcoholLicense.where(reported_at: reported_at).update_all(license_point_group_id: nil)
      LicensePointGroup.where(reported_at: reported_at).delete_all

      groups.each do |group|
        point_group = LicensePointGroup.create!(
          reported_at: reported_at,
          latitude: group.fetch(:latitude),
          longitude: group.fetch(:longitude),
          normalized_business_name: group.fetch(:normalized_business_name),
          display_business_name: group.fetch(:display_business_name),
          business_names: group.fetch(:business_names),
          business_ids: group.fetch(:business_ids),
          similarity_floor: group.fetch(:similarity_floor)
        )

        AlcoholLicense.where(id: group.fetch(:license_ids)).update_all(license_point_group_id: point_group.id)
      end
    end

    groups.size
  end

  private

  attr_reader :reported_at

  def geocoded_licenses
    AlcoholLicense
      .joins(:business, location: :transformed_location)
      .where(reported_at: reported_at)
      .where.not(transformed_locations: { latitude: nil, longtitude: nil })
      .select(
        'alcohol_licenses.id',
        'businesses.id AS business_id',
        'businesses.name AS business_name',
        'transformed_locations.latitude AS latitude',
        'transformed_locations.longtitude AS longitude',
        'transformed_locations.unit_number AS unit_number'
      )
      .to_a
  end

  def build_groups(licenses)
    licenses
      .group_by { |license| location_group_key(license) }
      .flat_map { |(latitude, longitude), location_licenses| groups_for_location(latitude, longitude, location_licenses) }
  end

  def location_group_key(license)
    [
      license.latitude,
      license.longitude,
      license.unit_number.to_s.presence
    ]
  end

  def groups_for_location(latitude, longitude, licenses)
    businesses = licenses.group_by(&:business_id).map do |business_id, business_licenses|
      business_name = business_licenses.first.business_name
      {
        business_id: business_id,
        business_name: business_name,
        normalized_name: BusinessNameNormalizer.normalize(business_name),
        normalized_token_key: BusinessNameNormalizer.normalized_token_key(business_name),
        license_ids: business_licenses.map(&:id)
      }
    end

    clusters = cluster_businesses(businesses)

    clusters.map do |cluster|
      license_ids = cluster.flat_map { |business| business.fetch(:license_ids) }
      business_names = cluster.map { |business| business.fetch(:business_name) }.uniq.sort
      business_ids = cluster.map { |business| business.fetch(:business_id) }.uniq.sort
      normalized_names = cluster.map { |business| business.fetch(:normalized_name) }.reject(&:blank?)

      {
        latitude: latitude,
        longitude: longitude,
        normalized_business_name: normalized_names.min_by(&:length).presence || "business:#{business_ids.first}",
        display_business_name: business_names.first,
        business_names: business_names,
        business_ids: business_ids,
        similarity_floor: similarity_floor(normalized_names),
        license_ids: license_ids
      }
    end
  end

  def cluster_businesses(businesses)
    clusters = []

    businesses.each do |business|
      matching_cluster = clusters.find do |cluster|
        cluster.all? { |candidate| similar_business?(business, candidate) }
      end

      if matching_cluster
        matching_cluster << business
      else
        clusters << [business]
      end
    end

    clusters
  end

  def similar_business?(left, right)
    left_name = left.fetch(:normalized_name)
    right_name = right.fetch(:normalized_name)
    left_token_key = left.fetch(:normalized_token_key)
    right_token_key = right.fetch(:normalized_token_key)
    return false if left_name.blank? || right_name.blank?
    return true if left_token_key.present? && left_token_key == right_token_key
    return true if business_name_alias?(left_token_key, right_token_key)

    BusinessNameNormalizer.similarity(left_name, right_name) >= SIMILARITY_THRESHOLD
  end

  def business_name_alias?(left_token_key, right_token_key)
    BUSINESS_NAME_ALIASES.include?(left_token_key) && BUSINESS_NAME_ALIASES.include?(right_token_key)
  end

  def similarity_floor(names)
    names = names.uniq
    return 1.0 if names.size < 2

    names.combination(2).map { |left, right| BusinessNameNormalizer.similarity(left, right) }.min
  end
end
