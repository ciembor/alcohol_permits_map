require 'test_helper'

class BusinessNameNormalizerTest < ActiveSupport::TestCase
  test 'normalizes legal form variants' do
    assert_equal(
      'WINIARNIA',
      BusinessNameNormalizer.normalize('WINIARNIA SPÓŁKA Z OGRANICZNĄ ODPOWIEDZIALNOŚCIĄ')
    )
    assert_equal(
      'REST KRAK GASTROX',
      BusinessNameNormalizer.normalize('REST - KRAK GASTROX SPÓŁKA Z OGRANICZONA ODPOWIEDZIALNOSCIA SPÓŁKA KOMANDYTOWA')
    )
    assert_equal(
      'BROWAR LUBICZ',
      BusinessNameNormalizer.normalize('BROWAR LUBICZ SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄSPÓŁKA KOMANDYTOWA')
    )
  end

  test 'builds order independent token key' do
    assert_equal(
      BusinessNameNormalizer.normalized_token_key('KAROLINA PACH'),
      BusinessNameNormalizer.normalized_token_key('PACH KAROLINA')
    )
    assert_equal(
      BusinessNameNormalizer.normalized_token_key('STUDNICKI KRZYSZTOF, STUDNICKI WOJCIECH'),
      BusinessNameNormalizer.normalized_token_key('STUDNICKI WOJCIECH, STUDNICKI KRZYSZTOF')
    )
  end

  test 'keeps meaningful business name qualifiers' do
    refute_equal(
      BusinessNameNormalizer.normalized_token_key('BONUS DEVELOPMENT SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ SPÓŁKA KOMANDYTOWA'),
      BusinessNameNormalizer.normalized_token_key('BONUS MANAGEMENT SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ SPÓŁKA KOMANDYTOWA')
    )
    refute_equal(
      BusinessNameNormalizer.normalized_token_key('WINE GARAGE GROUP SPÓŁKA Z O.O.'),
      BusinessNameNormalizer.normalized_token_key('WINE GARAGE SPÓŁKA Z OGRANICZONĄ ODPOWIEDZIALNOŚCIĄ SPÓŁKA KOMANDYTOWA')
    )
  end
end
