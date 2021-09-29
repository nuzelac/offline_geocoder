# https://snippets.aktagon.com/snippets/365-how-to-parse-geonames-org-data-with-ruby

require 'rubygems'
require 'ostruct'
require 'time'
require 'csv'
require 'byebug'

class GeoName < OpenStruct
end

class Country < OpenStruct
end

class Admin1 < OpenStruct
end

class Admin2 < OpenStruct
end

class GeoNames
  class << self
    def parse(file)
      File.new(file).each_line do |line|
        g = GeoName.new
        s = line.chomp.split("\t")
        g.geonameid = s[0]
        g.name = s[1]
        g.asciiname = s[2]
        g.alternatenames = s[3]
        g.latitude = s[4]
        g.longitude = s[5]
        g.feature_class = s[6]
        g.feature_code = s[7]
        g.country_code = s[8]
        g.cc2 = s[9]
        g.admin1 = s[10]
        g.admin2 = s[11]
        g.admin3 = s[12]
        g.admin4 = s[13]
        g.population = s[14]
        g.elevation = s[15]
        g.gtopo30 = s[16]
        g.timezone = s[17]
        g.modification_date = Time.parse(s[18])

        yield g
      end
    end
  end
end

class Countries
  class << self
    def parse(file)
      File.new(file).each_line do |line|
        g = Country.new
        s = line.chomp.split("\t")
        g.cc = s[0]
        g.name = s[4]
        yield g
      end
    end
  end
end

class Admin1s
  class << self
    def parse(file)
      File.new(file).each_line do |line|
        g = Admin1.new
        s = line.chomp.split("\t")
        g.id = s[0]
        g.name = s[2]
        yield g
      end
    end
  end
end

class Admin2s
  class << self
    def parse(file)
      File.new(file).each_line do |line|
        g = Admin2.new
        s = line.chomp.split("\t")
        g.id = s[0]
        g.name = s[2]
        yield g
      end
    end
  end
end

file = "cities500.txt"

countries = {}
Countries.parse("countryInfo.txt") do |country|
  countries[country.cc] = country.name
end

admin1s = {}
Admin1s.parse("admin1CodesASCII.txt") do |admin1|
  admin1s[admin1.id] = admin1.name
end

admin2s = {}
Admin2s.parse("admin2Codes.txt") do |admin2|
  admin2s[admin2.id] = admin2.name
end

# puts admin2s[""]

# byebug
i = 0
CSV.open("myfile.csv", "w") do |csv|
  csv << ["lat","lon","name","admin1","admin2","cc","country"]

  GeoNames.parse(file) do |place|
    # i += 1
    # if i == 150
    #   break
    # end
    csv << [place.latitude, place.longitude, place.asciiname, admin1s["#{place.country_code}.#{place.admin1}"], admin2s["#{place.country_code}.#{place.admin1}.#{place.admin2}"], place.country_code, countries[place.country_code]]
  end
end

