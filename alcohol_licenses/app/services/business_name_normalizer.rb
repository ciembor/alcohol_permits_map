require 'set'

class BusinessNameNormalizer
  STOPWORDS = %w[
    SPOLKA SPOL SP
    Z O OO ZO ZOO
    OGRANICZONA OGRANICZNA OGRANICZNEJ OGRAN ICZONA
    ODPOWIEDZIALNOSCIA ODPOWIEDZIALNOSCI
    ODPOWIEDZILANOSCIA ODPOWIEDZILANOSCI ODPOWIEDZILNOSCIA ODPOWIRDZIALNOSCIA
    ODPOWIEDIALNOSCIA ODPOWIEZIALNOSCIA ODPOWIEDZIANOSCIA ODPOWIEDZIALOSCIA
    JAWNA KOMANDYTOWA KOMADYTOWA KOMANDYTOWO AKCYJNA AKYJNA CYWILNA EUROPEJSKA
    SA SKA SC SJ SPJ SPK SPLKA
    FIRMA PRZEDSIEBIORSTWO PRZEDSIEBIORSTWA
    HANDLOWA HANDLOWE HANDLOWO HANDLOWY
    USLUGOWA USLUGOWE USLUGOWY USLUG USLUGI
    PRODUKCYJNA PRODUKCYJNO PRODUKCYJNE PRODUKCYJNY
    GASTRONOMICZNA GASTRONOMICZNE GASTRONOMICZNY
    TURYSTYCZNA TURYSTYCZNO TURYSTYCZNE
    WIELOBRANZOWA WIELOBRANZOWE
    WSPOLNICY WSPOLNIK
    GRUPA HOLDING COMPANY
    INVEST INVESTMENT INVESTMENTS
    TRADE TRADING SYSTEM SYSTEMS CONCEPT INTERNATIONAL
    KRAKOW KRAKOWIE KRAKOWSKI KRAKOWSKA KRAKOWSKIE
    CRACOW POLSKA POLAND POLSKIE POLSKI PL
    ODDZIAL SIEDZIBA DAWNIEJ
  ].to_set.freeze

  class << self
    def normalize(name)
      tokenize(name)
        .reject { |token| STOPWORDS.include?(token) || token.length == 1 }
        .join(' ')
    end

    def normalized_token_key(name)
      tokenize(name)
        .reject { |token| STOPWORDS.include?(token) || token.length == 1 }
        .sort
        .join(' ')
    end

    def similarity(left, right)
      left = normalize_for_similarity(left)
      right = normalize_for_similarity(right)
      return 1.0 if left == right
      return 0.0 if left.blank? || right.blank?

      max_length = [left.length, right.length].max
      1.0 - (levenshtein(left, right).to_f / max_length)
    end

    def tokenize(name)
      normalize_for_similarity(name)
        .gsub('ZOGRANICZONAODPOWIEDZIALNOSCIA', 'Z OGRANICZONA ODPOWIEDZIALNOSCIA')
        .gsub('ZOGRANICZONA', 'Z OGRANICZONA')
        .gsub('ODPOWIEDZIALNOSCIASPOLKA', 'ODPOWIEDZIALNOSCIA SPOLKA')
        .scan(/[A-Z0-9]+/)
    end

    private

    def normalize_for_similarity(value)
      ActiveSupport::Inflector
        .transliterate(value.to_s)
        .upcase
    end

    def levenshtein(left, right)
      previous = (0..right.length).to_a

      left.each_char.with_index(1) do |left_char, left_index|
        current = [left_index]

        right.each_char.with_index(1) do |right_char, right_index|
          cost = left_char == right_char ? 0 : 1
          current[right_index] = [
            current[right_index - 1] + 1,
            previous[right_index] + 1,
            previous[right_index - 1] + cost
          ].min
        end

        previous = current
      end

      previous.last
    end
  end
end
