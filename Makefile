CITATIONS_FILE=input/sqr_19906_MRP_boston_pd_citations_for_01012011_01012021.txt
ALPHA_LISTING_2020=input/ALPHa_LISTING_BPD_FRONT_DESK_Badges_included.xlsx
ALPHA_LISTING_2016=input/ALPHa_LISTING_BPD_with_badges_1.xlsx
CITATIONS_WITH_NAMES=output/boston_pd_citations_with_names_2011_2020.csv
CITATIONS_WITH_NAMES_XLSX=output/boston_pd_citations_with_names_2011_2020.xlsx

.EXPORT_ALL_VARIABLES:

.PHONY: all
all: $(CITATIONS_WITH_NAMES_XLSX) $(CITATIONS_WITH_NAMES)

.PHONY: clean-input
clean-input:
	rm -rf input
	mkdir -p input
	touch input/.keep

.PHONY: clean
clean:
	rm -rf output
	mkdir -p output
	touch output/.keep

.PHONY: deploy
deploy: $(CITATIONS_WITH_NAMES_XLSX) $(CITATIONS_WITH_NAMES)
	aws s3 cp $(CITATIONS_WITH_NAMES) 's3://wokewindows-data/' --acl public-read
	aws s3 cp $(CITATIONS_WITH_NAMES_XLSX) 's3://wokewindows-data/' --acl public-read

.PHONY: docker-build
docker-build:
	docker build -t boston_pd_citations .

.PHONY: docker-run
docker-run:
	docker run --rm --env-file env.list -v `pwd`:/volume -ti boston_pd_citations sh

# OUTPUT

$(CITATIONS_WITH_NAMES_XLSX): $(CITATIONS_WITH_NAMES)
	# output to /tmp/ b/c unoconv doesn't like the filename
	unoconv -i FilterOptions=44,34,76 -f xlsx -o /tmp/temp.xlsx $(CITATIONS_WITH_NAMES)
	mv /tmp/temp.xlsx $(CITATIONS_WITH_NAMES_XLSX)

$(CITATIONS_WITH_NAMES): $(CITATIONS_FILE) $(ALPHA_LISTING_2020) $(ALPHA_LISTING_2016)
	ruby lib/citations_with_names.rb

# INPUT

$(CITATIONS_FILE):
	wget 'https://wokewindows-data.s3.amazonaws.com/sqr_19906_MRP_boston_pd_citations_for_01012011_01012021.zip' -O input/sqr_19906_MRP_boston_pd_citations_for_01012011_01012021.zip
	unzip -p input/sqr_19906_MRP_boston_pd_citations_for_01012011_01012021.zip > $(CITATIONS_FILE)

$(ALPHA_LISTING_2020):
	wget 'https://cdn.muckrock.com/foia_files/2020/08/07/ALPHa_LISTING_BPD_FRONT_DESK_Badges_included.xlsx' -O $(ALPHA_LISTING_2020)

$(ALPHA_LISTING_2016):
	wget 'https://cdn.muckrock.com/foia_files/2016/07/26/ALPHa_LISTING_BPD_with_badges_1.xlsx' -O $(ALPHA_LISTING_2016)
