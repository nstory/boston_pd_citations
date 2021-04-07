require "ostruct"
require "roo"

# require "bundler/inline"

# gemfile do
#   source 'https://rubygems.org'
#   gem "roo", "2.8.3"
#   gem "pry"
# end

def roster_from_xlsx(xlsx_file, sheet)
  sheet = Roo::Spreadsheet.open(xlsx_file).sheet(sheet)
  sheet.each
    .drop(1) # drop header row
    .map do |row|
      # first column is employee id (IDNO6); second is full name
      OpenStruct.new id: row[0].to_i, name: row[1]
    end
end

def alpha_listing_2020
  roster_from_xlsx(ENV.fetch("ALPHA_LISTING_2020"), "ALPHa_LISTING_BPD_FRONT_DESK_B1")
end

def alpha_listing_2016
  roster_from_xlsx(ENV.fetch("ALPHA_LISTING_2016"), "ALPHa_LISTING_BPD_with_badges")
end

# {1234: "Smith,John", ...}
def create_id_to_name
  (alpha_listing_2020 + alpha_listing_2016)
    .group_by(&:id)
    .transform_values do |os|
      names = os.map(&:name).uniq
      if names.count == 1
        names.first
      else
        "#{names.first} (AKA #{names[1 .. -1].join('; ')})"
      end
    end
end

def citations
  io = File.new(ENV.fetch("CITATIONS_FILE"), "r", encoding: "UTF-8")
  io.read(3) # discard UTF-8 BOM
  csv = CSV.new(
    io,
    col_sep: "\t", # TSV
    row_sep: "\r\n", # DOS-style line-endings
    headers: true
  )
end

def write_citations_with_names
  headers = ["Issuing Agency", "Agency Code", "OfficerID", "Officer Name", "Event Date",
             "Time-HH", "Time-MM", "AM-PM", "Viol Type", "Citation #", "Citation Type", "Offense",
             "Offense Description", "Disposition", "Disposition Desc", "Location Name",
             "Searched", "Crash?", "Court Code", "Race", "Gender", "Year of Birth",
             "Lic State", "Lic Class", "CDL", "PlateType", "Vhc State", "Vhc Year",
             "Make Model", "Commercial", "Vhc Color", "16Pass", "HazMat", "Amount", "Paid?",
             "Hearing Requested?", "Speed", "Posted Speed", "Viol Speed", "Disposition Desc",
             "Posted", "Radar", "Clocked", "Officer Cert"]

  id_to_name = create_id_to_name

  CSV.open(ENV.fetch("CITATIONS_WITH_NAMES"), "w", encoding: "UTF-8") do |csv|
    csv << headers

    # CITATIONS_FILE contains every agency with "Boston" in its name, filter it down
    # to just BPD
    citations.lazy.select { |c| /Boston Police/ =~ c["Issuing Agency"] }
      .each do |citation|
        # join the citation to the name on officer's id (aka IDNO6)
        citation_with_name = citation.to_h
          .merge({"Officer Name" => id_to_name[citation["OfficerID"].to_i]})

        # write out values in order dictated by headers
        csv << headers.map { |h| citation_with_name[h] }
      end
  end
end

write_citations_with_names
