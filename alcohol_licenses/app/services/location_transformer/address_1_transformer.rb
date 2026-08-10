require 'set'

class LocationTransformer::Address1Transformer

  def initialize(abbreviations:, not_unique_words:, streets:)
    @abbreviations = abbreviations
    @not_unique_words = not_unique_words
    @streets = streets
    @street_index = build_street_index
    @normalization_cache = {}
  end

  def transform_address_1(address_1)
    return if address_1.blank?

    return normalization_cache[address_1] if normalization_cache.key?(address_1)

    normalized_address = normalized_key(address_1)
    exact_match = street_index[normalized_address]

    return normalization_cache[address_1] = exact_match if exact_match

    subset_match = token_subset_match(normalized_address)

    return normalization_cache[address_1] = subset_match if subset_match

    normalization_cache[address_1] = nil
  end

  def same_as_for(address_1)
    historical_street_renames[normalized_key(address_1)]&.fetch(:new_name)
  end

  private

  attr_accessor :abbreviations, :not_unique_words, :streets, :street_index, :normalization_cache

  MANUAL_REPLACEMENTS = {
    'MASZALKA' => 'MARSZALKA',
    'FERDYNANDA' => 'FERDINANDA',
    'KAOLEMJAO GREONW STKAIDEGEUOSZA' => '',
    'KAOLEMJAO GREONW. STKAIDEGEUOSZA' => ''
  }.freeze

  HISTORICAL_STREET_RENAMES = [
    { old_name: 'Braci Czeczów', new_name: 'Henryka i Karola Czeczów' },
    { old_name: 'Emila Dziedzica', new_name: 'Marka Eminowicza' },
    { old_name: 'Franciszka Kajty', new_name: 'prof. Henryka Wereszyckiego' },
    { old_name: 'Zygmunta Młynarskiego', new_name: 'Marka Nawary' },
    { old_name: 'Lucjana Szenwalda', new_name: 'Majora Pilota Stefana Janusa' },
    { old_name: 'Janka Szumca', new_name: 'Wiktora Zina', aliases: ['Jana Szumca', 'Szumca'] },
    { old_name: 'Jana Szwai', new_name: 'prof. Władysława Konopczyńskiego' },
    { old_name: 'Ignacego Kriegera', new_name: 'Rodziny Kriegerów' }
  ].freeze

  SOURCE_STREET_CORRECTIONS = {
    'Plac Targowy Stary Kleparz' => 'Rynek Kleparski',
    'Przylasek Rusiecki' => 'Przylasek',
    'Teren Przy Zalewie Nowohuckim' => 'Nad Zalewem',
    'Zalew Nowohucki' => 'Nad Zalewem'
  }.freeze

  ADDITIONAL_OFFICIAL_STREET_NAMES = [
    'Romana Ciesielskiego',
    'Żywiecka Boczna'
  ].freeze

  WORD_REPLACEMENTS = {
    'AL' => 'ALEJA',
    'AL.' => 'ALEJA',
    'ALEJE' => 'ALEJA',
    'OS' => 'OSIEDLE',
    'OS.' => 'OSIEDLE',
    'OŚ' => 'OSIEDLE',
    'OŚ.' => 'OSIEDLE',
    'PL' => 'PLAC',
    'PL.' => 'PLAC',
    'UL' => '',
    'UL.' => '',
    'ULICA' => '',
    'SW' => 'SWIETEGO',
    'SW.' => 'SWIETEGO',
    'SWIETEJ' => 'SWIETEGO',
    'ŚW' => 'SWIETEGO',
    'ŚW.' => 'SWIETEGO',
    'ŚWIĘTEJ' => 'SWIETEGO',
    'ŚWIĘTEGO' => 'SWIETEGO',
    'GEN' => 'GENERAL',
    'GEN.' => 'GENERAL',
    'GENERALA' => 'GENERAL',
    'GENERAŁA' => 'GENERAL',
    'MARSZAŁKA' => 'MARSZALKA',
    'MARSZ' => 'MARSZALKA',
    'MARSZ.' => 'MARSZALKA',
    'PUŁKOWNIKA' => 'PLK',
    'PULKOWNIKA' => 'PLK',
    'PŁK' => 'PLK',
    'PŁK.' => 'PLK',
    'PLK' => 'PLK',
    'PLK.' => 'PLK',
    'KSIĘDZA' => 'KSIEDZA',
    'KS' => 'KSIEDZA',
    'KS.' => 'KSIEDZA',
    'DR' => 'DOKTORA',
    'DR.' => 'DOKTORA',
    'PROF' => 'PROFESORA',
    'PROF.' => 'PROFESORA',
    'BISKUPA' => 'BP',
    'BP' => 'BP',
    'BP.' => 'BP',
    'ARCYBISKUPA' => 'ABP',
    'ABP' => 'ABP',
    'ABP.' => 'ABP',
    'MAJORA' => 'MAJORA',
    'PORUCZNIKA' => 'PORUCZNIKA',
    'ROTMISTRZA' => 'ROTMISTRZA'
  }.freeze

  IGNORED_MATCH_TOKENS = [
    'ALEJA',
    'OSIEDLE',
    'PLAC',
    'GENERAL',
    'MARSZALKA',
    'PLK',
    'DOKTORA',
    'KSIEDZA',
    'PROFESORA',
    'BP',
    'ABP',
    'MAJORA',
    'PORUCZNIKA',
    'ROTMISTRZA'
  ].freeze

  POLISH_REPLACEMENTS = {
    'Ą' => 'A',
    'Ć' => 'C',
    'Ę' => 'E',
    'Ł' => 'L',
    'Ń' => 'N',
    'Ó' => 'O',
    'Ś' => 'S',
    'Ź' => 'Z',
    'Ż' => 'Z'
  }.freeze

  def build_street_index
    primary_variant_groups = Hash.new { |hash, key| hash[key] = Set.new }
    secondary_variant_groups = Hash.new { |hash, key| hash[key] = Set.new }

    streets.each do |street|
      canonical = canonical_street_name(street)

      primary_street_variants(street).each do |variant|
        key = normalized_key(variant)
        primary_variant_groups[key] << canonical if key.present?
      end

      secondary_street_variants(street).each do |variant|
        key = normalized_key(variant)
        secondary_variant_groups[key] << canonical if key.present?
      end
    end

    index = primary_variant_groups.each_with_object({}) do |(key, candidates), result|
      result[key] = candidates.first if candidates.one?
    end

    secondary_variant_groups.each_with_object(index) do |(key, candidates), result|
      next if result.key?(key)

      result[key] = candidates.first if candidates.one?
    end

    historical_street_renames.each_with_object(index) do |(key, rename), result|
      result[key] ||= rename.fetch(:old_name)
    end

    SOURCE_STREET_CORRECTIONS.each_with_object(index) do |(source_name, canonical_name), result|
      result[normalized_key(source_name)] ||= canonical_name
    end

    ADDITIONAL_OFFICIAL_STREET_NAMES.each_with_object(index) do |street_name, result|
      result[normalized_key(street_name)] ||= street_name
    end
  end

  def historical_street_renames
    @historical_street_renames ||= HISTORICAL_STREET_RENAMES.each_with_object({}) do |rename, result|
      ([rename.fetch(:old_name)] + Array(rename[:aliases])).each do |old_name_variant|
        result[normalized_key(old_name_variant)] = {
          old_name: rename.fetch(:old_name),
          new_name: rename.fetch(:new_name)
        }
      end
    end
  end

  def primary_street_variants(street)
    name_1, name_2 = street

    [
      canonical_street_name(street),
      [name_1, name_2].compact.join(' '),
      without_leading_kind(canonical_street_name(street)),
      without_leading_kind(name_1),
      name_1
    ].compact
  end

  def secondary_street_variants(street)
    name_1, name_2 = street
    base_variants = [
      name_2
    ].compact

    (base_variants + primary_street_variants(street).flat_map { |variant| shortened_patron_variants(variant) }).compact
  end

  def street_variants(street)
    (primary_street_variants(street) + secondary_street_variants(street)).compact
  end

  def canonical_street_name(street)
    street.compact.reverse.join(' ').squeeze(' ').strip
  end

  def without_leading_kind(value)
    return if value.blank?

    value
      .sub(/\A(Aleja|Aleje|Osiedle|Plac|Ulica)\s+/i, '')
      .sub(/\A(al\.|os\.|pl\.|ul\.)\s+/i, '')
  end

  def shortened_patron_variants(value)
    words = value.to_s.split
    return [] if words.length < 3

    prefixes = []
    prefixes << words.shift if words.first&.match?(/\A(Aleja|Aleje|Plac|Osiedle|Ulica|al\.|pl\.|os\.|ul\.)\z/i)
    prefixes << words.shift if words.first&.match?(/\A(gen\.?|generała|marsz\.?|marszałka|płk\.?|pułkownika|dr\.?|doktora|ks\.?|księdza|prof\.?|profesora|bp\.?|biskupa|abp\.?|arcybiskupa|majora|porucznika|rotmistrza)\z/i)

    return [] if prefixes.empty? || words.length < 2

    [
      (prefixes + [words.last]).join(' '),
      (prefixes + words.last(2)).join(' ')
    ]
  end

  def normalized_key(value)
    value = value.to_s.dup.force_encoding('UTF-8').encode('UTF-8', invalid: :replace, undef: :replace, replace: '').upcase
    POLISH_REPLACEMENTS.each do |from, to|
      value = value.gsub(from, to)
    end
    value = ActiveSupport::Inflector.transliterate(value)
    value = value.gsub(/\s*-\s*/, '-')
    value = value.gsub(/[.,]/, ' ')
    value = value.gsub(/[^A-Z0-9 -]/, ' ')

    MANUAL_REPLACEMENTS.each do |from, to|
      value = value.gsub(from, to)
    end

    value
      .split
      .map { |word| WORD_REPLACEMENTS.fetch(word, word) }
      .reject(&:blank?)
      .join(' ')
      .squeeze(' ')
      .strip
  end

  def token_subset_match(normalized_address)
    tokens = normalized_address.split
    return if tokens.length < 2

    matches = street_index.filter_map do |street_key, street_name|
      street_tokens = street_key.split

      comparable_tokens = tokens - IGNORED_MATCH_TOKENS
      comparable_street_tokens = street_tokens - IGNORED_MATCH_TOKENS

      next if comparable_tokens.length < 2
      next unless (comparable_tokens - comparable_street_tokens).empty?

      overlap = (comparable_tokens & comparable_street_tokens).length
      next if overlap.zero?

      [street_name, overlap, comparable_street_tokens.length]
    end

    best_score = matches.map { |_street_name, overlap, street_length| [overlap, street_length] }.max
    best_matches = matches.select { |_street_name, overlap, street_length| [overlap, street_length] == best_score }.map(&:first).uniq

    best_matches.first if best_matches.one?
  end

end
