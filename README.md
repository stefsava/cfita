# Cfita

Check italian fiscal code

Intentionally this gem does not claim to "calculate" the tax code, which can be issued by the tax authorities of the Italian Republic (Revenue Agency).

see:
https://www.agenziaentrate.gov.it/wps/content/Nsilib/Nsi/Schede/Istanze/Richiesta+TS_CF/Informazioni+codificazione+pf

The purpose that it intends to achieve is exclusively to check if the personal data of the subject are consistent with the tested code.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cfita'
```

And then execute:

```shell
bundle
```
## Usage

```ruby
require 'cfita'

p Cfita::CodiceFiscale.new('AAABBB50A50F839X')
=> #<Cfita::CodiceFiscale:0x00007fa4efd09558 @fiscal_code="AAABBB50A50F839X", @birth_place=nil, @birth_date=nil, @name=nil, @surname=nil, @sex=nil, @errors=["Checksum errato"]>

p Cfita::CodiceFiscale.new(
  'AAABBB50A50F839U',
  birth_place: 'Roma',
  birth_date: '19600530',
  sex: 'M',
  name: 'MARIO',
  surname: 'Rossi'
 )
=> #<Cfita::CodiceFiscale:0x00007fa4e75abf98 @fiscal_code="AAABBB50A50F839U", @birth_place="ROMA", @birth_date=Mon, 30 May 1960, @name="MARIO", @surname="ROSSI", @sex="M", @errors=["Il nome non corrisponde al codice 'MRA'", "Il cognome non corrisponde al codice 'RSS'", "Luogo di nascita ROMA non coerente, al codice catastale F839 corrisponde a NAPOLI", "Sesso errato"]>

```

## Contributing

1. Fork it ( https://github.com/stefsava/cfita/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
