module LocationTransformer
  class Address2Transformer
    PARCEL_NUMBER_PATTERN = /\d+(?:\/\d+)?/.freeze
    PARCEL_MARKER_PATTERN = '(?:działk[ai]?|dzialk[ai]?|dzoałka|dzxiałki|dz\.?\s*nr\.?|dz\.?nr\.?|dzi\.?|dz\.?)'.freeze

    def transform(address_2)
      normalized_address = normalize(address_2)

      return landmark(address_2) if normalized_address.blank?

      if near_building?(normalized_address)
        return near_building(address_2, normalized_address)
      end

      if parcel?(normalized_address)
        return parcel(address_2, normalized_address)
      end

      if pavilion?(normalized_address)
        return pavilion(address_2, normalized_address)
      end

      if building_marker_at_the_beginning?(normalized_address) || number_at_the_beginning?(normalized_address)
        return street_address(address_2, normalized_address)
      end

      landmark(address_2)
    end

    def building_number(address_2)
      transform(address_2)[:building_number]
    end

    private

    def normalize(address_2)
      address_2.to_s
        .dup
        .force_encoding('UTF-8')
        .encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
        .strip
        .sub(/\A%+(\d+[[:alpha:]]?)%+\z/i, '\1')
        .squeeze(' ')
    end

    def number_at_the_beginning?(address_2)
      /\A\d+\s*[[:alpha:]]?/i.match?(address_2)
    end

    def building_marker_at_the_beginning?(address_2)
      /\A(?:nr\.?|ok\.?)\s*\d+/i.match?(address_2)
    end

    def near_building?(address_2)
      /\b(?:przy|obok|koło|kolo|k[\/.]|p\.?\s*bl|ob\s*bl|k\/bud\.?|przy\s+bud\.?|bl\.?)\.?\s*(?:bud(?:ynku)?\.?\s*)?(?:bl(?:oku)?\.?\s*)?(?:nr\.?\s*)?\d+/i.match?(address_2)
    end

    def pavilion?(address_2)
      /\A(?:paw\.?|pawilon|p\s*paw\.?)\s*(?:nr\.?\s*)?\d*/i.match?(address_2) ||
        /\bpaw(?:\.|ilon)?\s*(?:nr\.?\s*)?\d+/i.match?(address_2) ||
        /\A(?:kiosk)\s*(?:nr\.?\s*)?\d+/i.match?(address_2)
    end

    def parcel?(address_2)
      /\b#{PARCEL_MARKER_PATTERN}\s*(?:(?:nr\.?|ewid(?:\.|encyjna|encyjny)?)\s*)*#{PARCEL_NUMBER_PATTERN}/i.match?(address_2)
    end

    def street_address(address_2, normalized_address)
      {
        address_kind: compound_address?(normalized_address) ? 'compound_address' : 'street_address',
        address_relation: nil,
        building_number: extract_building_number(normalized_address),
        unit_number: extract_unit_number(normalized_address),
        parcel_number: extract_parcel_number(normalized_address),
        parcel_region: extract_parcel_region(normalized_address),
        parcel_cadastral_unit: extract_parcel_cadastral_unit(normalized_address),
        raw_address_2: address_2
      }
    end

    def near_building(address_2, normalized_address)
      {
        address_kind: 'near_building',
        address_relation: 'near',
        building_number: extract_near_building_number(normalized_address),
        unit_number: extract_unit_number(normalized_address),
        parcel_number: extract_parcel_number(normalized_address),
        parcel_region: extract_parcel_region(normalized_address),
        parcel_cadastral_unit: extract_parcel_cadastral_unit(normalized_address),
        raw_address_2: address_2
      }
    end

    def pavilion(address_2, normalized_address)
      {
        address_kind: 'pavilion',
        address_relation: nil,
        building_number: number_at_the_beginning?(normalized_address) ? extract_building_number(normalized_address) : nil,
        unit_number: extract_pavilion_number(normalized_address),
        parcel_number: extract_parcel_number(normalized_address),
        parcel_region: extract_parcel_region(normalized_address),
        parcel_cadastral_unit: extract_parcel_cadastral_unit(normalized_address),
        raw_address_2: address_2
      }
    end

    def parcel(address_2, normalized_address)
      {
        address_kind: 'parcel',
        address_relation: nil,
        building_number: number_at_the_beginning?(normalized_address) ? extract_building_number(normalized_address) : nil,
        unit_number: extract_unit_number(normalized_address),
        parcel_number: extract_parcel_number(normalized_address),
        parcel_region: extract_parcel_region(normalized_address),
        parcel_cadastral_unit: extract_parcel_cadastral_unit(normalized_address),
        raw_address_2: address_2
      }
    end

    def landmark(address_2)
      {
        address_kind: 'landmark',
        address_relation: nil,
        building_number: nil,
        unit_number: extract_unit_number(address_2),
        parcel_number: nil,
        parcel_region: nil,
        parcel_cadastral_unit: nil,
        raw_address_2: address_2
      }
    end

    def extract_building_number(address_2)
      extract_first_number_with_letter(address_2)
    end

    def extract_first_number_with_letter(address_2)
      normalized_address = address_2.to_s.upcase

      leading_marker_match = normalized_address.match(/\A\s*(?:NR\.?|OK\.?)\s*(\d+[[:alpha:]]?)/)
      return leading_marker_match[1] if leading_marker_match

      described_unit_match = normalized_address.match(
        /\A\s*(\d+)\s+(?:L(?:\.|\d+\b|OK(?:AL)?\.?\b|U\b|K\.?\b|NM\b|M\d*\b)|LLOK\.?\b|U\d*\b|PAW|KIOSK|POZIOM|POZ\.?|P(?:\.|\b)|PRZYZIEMIE|IP\.?|IIP\.?|IIIP\.?|IVP\.?|SEG(?:\.|M\.?|MENT)?\b|STOISKO|HALA|BOKS|NR\b|WEJ(?:Ś|S)CIE\b)/
      )
      return described_unit_match[1] if described_unit_match

      separator_match = normalized_address.match(/\A\s*(\d+)\s*(?:\/|LOK|LO|LU|PAW|BUD(?:\.|YNEK|YNKU)?\b|\.|,|;|-|\z)/)
      return separator_match[1] if separator_match

      compact_letter_match = normalized_address.match(/\A\s*(\d+)([[:alpha:]])/)
      return compact_letter_match.captures.join if compact_letter_match

      spaced_letter_match = normalized_address.match(/\A\s*(\d+)\s+([[:alpha:]])\b(.*)\z/)
      if spaced_letter_match
        building_number, letter, rest = spaced_letter_match.captures
        return building_number if letter == 'I' && rest.match?(/\A\s+\d/)

        return "#{building_number}#{letter}"
      end

      normalized_address.match(/\A\s*(\d+)/)&.captures&.first
    end

    def extract_near_building_number(address_2)
      address_2
        .match(/\b(?:przy|obok|koło|kolo|k[\/.]|p\.?\s*bl|ob\s*bl|k\/bud\.?|przy\s+bud\.?|bl\.?)\.?\s*(?:bud(?:ynku)?\.?\s*)?(?:bl(?:oku)?\.?\s*)?(?:nr\.?\s*)?(\d+[[:alpha:]]?)/i)
        &.captures
        &.first
    end

    def extract_unit_number(address_2)
      address = address_2.to_s
      return if second_address_after_slash?(address)

      unit_address = unit_address_segment(address)
      normalize_unit_number(
        unit_from_local_marker(unit_address) ||
        unit_from_slash(unit_address) ||
        unit_from_described_marker(unit_address),
        address
      )
    end

    def extract_pavilion_number(address_2)
      address_2.match(/\b(?:paw\.?|pawilon|p\s*paw\.?|kiosk)\s*(?:nr\.?\s*)?([0-9]+[[:alpha:]]?)/i)&.captures&.first
    end

    def normalize_unit_number(unit_number, address)
      return if unit_number.blank?

      if unit_number.match?(/\A\d+i\z/i) && address.match?(/\b#{Regexp.escape(unit_number)}\s+\d/i)
        return unit_number[0...-1].upcase
      end

      normalized_unit_number = unit_number.to_s.gsub(/[\s"]+/, '').upcase
      normalized_unit_number.sub(/\A0U/, 'OU')
    end

    def unit_from_local_marker(address)
      address.match(
        /(?:\A\s*\d+\s*[[:alpha:]]?\s*|(?<=\d)|\b)l+ok(?:al)?\.?\s*(?:nr\.?\s*)?(?:LU|U|OU|LO)\s*[-.\/]?\s*([0-9]+[[:alpha:]]*)\b/i
      )&.captures&.first ||
        address.match(
          /(?:\A\s*\d+\s*[[:alpha:]]?\s*|(?<=\d)|\b)(?:l+ok(?:al)?\.?|l\.)\s*(?:nr\.?\s*)?[-.\/]?\s*([0-9]+\s+(?!i\b)[[:alpha:]]\b(?!\s*\d)|[0-9]+[[:alpha:]]*|[[:alpha:]]+\s*[0-9]+[[:alpha:]]*|[IVXLCDM]+|[[:alpha:]])\b/i
        )&.captures&.first ||
        address.match(
          /\b(?:LU|U(?!L\.?))\s*(?:nr\.?\s*)?[-.]?\s*([0-9]+[[:alpha:]]*|[IVXLCDM]+|[[:alpha:]])\b/i
        )&.captures&.first
    end

    def unit_from_slash(address)
      normalized_address = address.to_s.strip
      match = normalized_address.match(
        /\A\s*\d+\s*[[:alpha:]]?\s*\/\s*(?:(?:LU|U|LO|L)(?=\s*[0-9])\s*)?(?:"?U"?(?=\s*[0-9])\s*)?([0-9]+(?:\.[0-9]+|[[:alpha:]]+[0-9]*|"?[[:alpha:]]+"?)?|[[:alpha:]]+[-.\s]?[0-9]+[[:alpha:]]*(?:\.[0-9]+)?|LU|U|P|[IVXLCDM]+|[[:alpha:]])(?=\s|[,;\/-]|\z)(.*)\z/i
      )
      return unless match

      unit_number = match[1]
      rest = match[2].to_s.strip
      after_slash = normalized_address.split('/', 2).last.to_s.strip
      return if after_slash.match?(/\A(?:ul\.?|aleja|al\.?|plac|pl\.?|rynek|osiedle|os\.?|św\.?|sw\.?|[[:alpha:]]{4,})\s+[0-9]/i)
      return if rest.match?(/\//)
      return if rest.match?(/\b(?:ul\.?|aleja|al\.?|plac|pl\.?|rynek|osiedle|os\.?|św\.?|sw\.?)\b/i)
      return unless rest.blank? || rest.match?(/\A(?:[,;-]\s*[0-9[:alpha:]]+|\s*i\s*[0-9[:alpha:]]+|\s*[[:alpha:]]?\s*)+\z/i)

      unit_number
    end

    def second_address_after_slash?(address)
      after_slash = address.to_s.split('/', 2).second.to_s.strip
      return false if after_slash.blank?
      return false if after_slash.match?(/\A(?:kiosk|paw\.?|pawilon|p\s*paw\.?|lok(?:al)?\.?|lu|u|lo)\b/i)

      slash_parts = after_slash.split('/').map(&:strip)
      slash_parts.any? do |part|
        part.match?(/\b(?:ul\.?|aleja|al\.?|plac|pl\.?|rynek|osiedle|os\.?|św\.?|sw\.?)\s*[[:alpha:]]*\s*[0-9]/i) ||
          part.match?(/\A[[:alpha:]]{4,}\.?\s*[0-9]/i)
      end
    end

    def unit_from_described_marker(address)
      address.match(
        /\b(?:paw\.?|pawilon|p\s*paw\.?|kiosk|stoisko|hala|boks|bok)\s*(?:nr\.?\s*)?([0-9]+[[:alpha:]]?|[[:alpha:]]+[0-9]+|[[:alpha:]])\b/i
      )&.captures&.first
    end

    def unit_address_segment(address)
      address.to_s.split(/[;,]/, 2).first.to_s
    end

    def extract_parcel_number(address_2)
      parcel_text = address_2
        .to_s
        .match(/\b#{PARCEL_MARKER_PATTERN}\s*(?:(?:nr\.?|ewid(?:\.|encyjna|encyjny)?)\s*)*(.+?)(?:\bobr(?:ęb)?\.?|\bj\.?\s*e\.?\b|\bstr(?:efa)?\b|\bk\.?\s*bl\b|\z)/i)
        &.captures
        &.first
      return unless parcel_text

      parcel_text
        .scan(PARCEL_NUMBER_PATTERN)
        .uniq
        .join('|')
        .presence
    end

    def extract_parcel_region(address_2)
      if address_2.match(/obr(?:ęb)?\.?\s*(?:nr\.?\s*)?(?:[A-Z]\s*-\s*)?([0-9]{1,4}(?:\s*,\s*[0-9]{1,4})*)/i)
        Regexp.last_match(1)
          .scan(/[0-9]{1,4}/)
          .map { |number| number.to_i.to_s }
          .uniq
          .join('|')
      elsif address_2.match(/\b[0-9]{1,3}-0*([0-9]{1,4})\b/)
        Regexp.last_match(1).to_i.to_s
      end
    end

    def extract_parcel_cadastral_unit(address_2)
      normalized_address = address_2.to_s.downcase
      return 'srodmiescie' if normalized_address.match?(/śród|srod|śrd|srd/)
      return 'podgorze' if normalized_address.match?(/podg/)
      return 'nowa_huta' if normalized_address.match?(/nowa\s*huta|nh/)
      return 'krowodrza' if normalized_address.match?(/krow/)

      'krowodrza' if address_2.match?(/\b[0-9]{1,3}-0*([0-9]{1,4})\b/)
    end

    def compound_address?(address_2)
      address_2.match?(/[,;]\s*\d+\s*[[:alpha:]]?\b/i) ||
        address_2.match?(/\b\d+\s*[[:alpha:]]?\s+i\s+\d+\s*[[:alpha:]]?\b/i)
    end
  end
end
