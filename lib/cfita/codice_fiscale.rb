# frozen_string_literal: true

require 'active_support/all'
require 'cfita/codici_catastali'

module Cfita
  # Controllo codice fiscale italiano
  class CodiceFiscale
    attr_reader :fiscal_code,
                :sex,
                :birth_place,
                :birth_date,
                :errors

    def self.ccat
      @ccat ||= JSON.parse(open('ccat.json'))
    end

    def initialize(
      fiscal_code,
      birth_place: nil,
      birth_date: nil,
      name: nil,
      surname: nil,
      sex: nil
    )
      @fiscal_code = fiscal_code.upcase.strip
      @birth_place = birth_place&.upcase
      @birth_date = birth_date
      @birth_date = Date.parse(birth_date) if birth_date.is_a?(String)
      @name = name&.parameterize&.upcase
      @surname = surname&.parameterize&.upcase
      @sex = sex&.upcase
      @errors = []
      parse
    end

    def to_s
      fiscal_code
    end

    def valid?
      errors.empty?
    end

    def cf_sex
      return @cf_sex if @cf_sex
      case @fiscal_code[9]
      when /[0-3LMNP]/
        @cf_sex = 'M'
      when /[4-7QRST]/
        @cf_sex = 'F'
      else
        @errors << 'Cifra decina giorno di nascita errata'
      end
    end

    def cf_birth_places
      return @cf_birth_places if @cf_birth_places

      @cf_birth_places = CODICI_CATASTALI[codice_catastale]
    end

    def cf_birth_date
      return @cf_birth_date if @cf_birth_date
      yy = cifre(6..7)
      return if @errors.any?

      day = cifre(9..10)
      return if @errors.any?

      @errors << 'Cifra decina giorno di nascita errata' if day > 71
      return if @errors.any?

      month = MESI.index(@fiscal_code[8])
      @errors << 'Mese errato' unless month
      return if @errors.any?

      @cf_birth_date = Date.new(yy2yyyy(yy), month + 1, day % 40) rescue nil
    end

    private

    def codice_catastale 
      return @codice_catastale if @codice_catastale
      letter = @fiscal_code[11]
      numbers =
        @fiscal_code[12..14]
        .split(//)
        .map do |c|
          i = OMOCODICI.index(c)
          i ? i.to_s : c
        end
        .join
      letter + numbers
    end

    def parse
      check_size
      check_chars
      return if errors.any?

      check_checksum
      return if errors.any?

      check_name
      check_surname
      check_birth_date
      check_birth_place
      check_sex
    end

    def check_name
      return unless @name

      a, b, c, d = consonants(@name)
      name_code = (
        (d ? [a, c, d] : [a, b, c]).compact.join +
        vowels(@name).join +
        'XXX'
      )[0..2]

      errors << "Il nome non corrisponde al codice '#{name_code}'" unless name_code == @fiscal_code[3..5]
    end

    def check_surname
      return unless @surname

      surname_code = (
        consonants(@surname).join +
        vowels(@surname).join +
        'XXX'
      )[0..2]

      errors << "Il cognome non corrisponde al codice '#{surname_code}'" unless surname_code == @fiscal_code[0..2]
    end

    VOWELS = 'AEIOU'.chars.freeze
    CONSONANTS = (('A'..'Z').to_a - VOWELS).freeze

    def vowels(word)
      word.chars.select { |char| char.in? VOWELS }
    end

    def consonants(word)
      word.chars.select { |char| char.in? CONSONANTS }
    end

    def check_size
      size = @fiscal_code.size
      errors << "Lunghezza errata (#{size})" unless size == 16
    end

    def check_chars
      test = @fiscal_code == @fiscal_code[/^[A-Z0-9]*$/]
      errors << 'Caratteri non ammessi' unless test
    end

    def check_checksum
      errors << 'Checksum errato' if checksum != @fiscal_code.last
    end

    def check_sex
      if @sex
        errors << 'Sesso errato' if @sex != cf_sex
      else
        @sex = cf_sex
      end
    end

    def check_birth_place
      @errors << "Codice istat #{codice_catastale} non trovato" unless cf_birth_places
      if @birth_place
        unless cf_birth_places&.include?(@birth_place)
          @errors << "Luogo di nascita #{@birth_place} non coerente, al codice catastale #{codice_catastale} corrisponde a #{cf_birth_places.join(' o a ')}"
        end
      end
    end

    MESI = 'ABCDEHLMPRST'

    def yy2yyyy(year_as_yy)
      Date.today.year -
        (Date.today.year % 100 + 100 - year_as_yy) % 100
    end

    def check_birth_date
      @errors << 'Data di nascita errata' unless cf_birth_date
      return if @errors.any?

      if @birth_date
        @errors << 'Data di nascita errata' if @birth_date != cf_birth_date
      else
        @birth_date = cf_birth_date
      end
    end

    def cifre(range)
      result = 0
      range.each do |position|
        char = @fiscal_code[position]
        value = CIFRE.index(char)
        @errors << "Carattere '#{char}' errato in posizione #{position}" unless value
        return nil unless value

        result *= 10
        result += value % 10
      end
      result
    end

    DISPARI = [
      1, 0, 5, 7, 9,
      13, 15, 17, 19, 21,
      2, 4, 18, 20, 11,
      3, 6, 8, 12, 14,
      16, 10, 22, 25, 24, 23
    ].freeze

    OMOCODICI = 'LMNPQRSTUV'
    CIFRE = ('0123456789' + OMOCODICI).freeze

    def checksum
      tot = 0
      @fiscal_code[0..14].bytes.first(15).each.with_index do |byte, i|
        next unless byte

        byte -= byte < 65 ? 48 : 65
        sign = (i % 2).zero?
        tot += sign ? DISPARI[byte] : byte
      end
      (tot % 26 + 65).chr
    end
  end
end
