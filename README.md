# Cfita

Check italian fiscal code

see:
https://www.agenziaentrate.gov.it/wps/content/Nsilib/Nsi/Schede/Istanze/Richiesta+TS_CF/Informazioni+codificazione+pf


today_year = 1965 ; (0..99).each {|year|  p  [year, [1800,1900,2000].map {|mill| today_year - (mill + year)}.reject{|x| x < 14 }.min ].flatten }
