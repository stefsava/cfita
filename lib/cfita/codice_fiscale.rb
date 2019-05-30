# frozen_string_literal: true

require 'active_support/all'

module Cfita
  # Controllo codice fiscale italiano
  class CodiceFiscale
    attr_reader :codice_fiscale, :data, :errors, :sesso

    def initialize(codice_fiscale)
      @codice_fiscale = codice_fiscale.upcase.strip
      @data = {}
      @errors = []
      parse
    end

    def to_s
      codice_fiscale
    end

    def valid?
      errors.empty?
    end

    private

    def parse
      check_size
      check_chars
      return if errors.any?

      check_checksum
      return if errors.any?

      check_sex
    end

    def check_size
      size = @codice_fiscale.size
      errors << "Lunghezza errata (#{size})" unless size == 16
    end

    def check_chars
      test = @codice_fiscale == @codice_fiscale.parameterize.upcase[/^[A-Z0-9]*$/]
      errors << 'Caratteri non ammessi' unless test
    end

    def check_checksum
      errors << 'Checksum errato' if checksum != @codice_fiscale.last
    end

    def check_sex
      case @codice_fiscale[9]
      when /[0-3LMNP]/
        @data[:sesso] = 'M'
      when /[4-7QRST]/
        @data[:sesso] = 'F'
      else
        @errors << 'Cifra decina giorno di nascita errata'
      end
    end

    DISPARI = [
      1, 0, 5, 7, 9,
      13, 15, 17, 19, 21,
      2, 4, 18, 20, 11,
      3, 6, 8, 12, 14,
      16, 10, 22, 25, 24, 23
    ].freeze

    OMOCODICI = 'LMNPQRSTUV'

    def checksum
      tot = 0
      @codice_fiscale[0..14].bytes.first(15).each.with_index do |byte, i|
        next unless byte

        byte -= byte < 65 ? 48 : 65
        sign = (i % 2).zero?
        tot += sign ? DISPARI[byte] : byte
      end
      (tot % 26 + 65).chr
    end
  end
end
