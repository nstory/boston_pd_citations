# Boston Police Citations
Traffic Citations written by Boston Police from 2011 to 2020.

## Download
**TL;DR** you will want to download one of these files; each contains all traffic citations written by Boston Police from 2011 to 2020 and include the name of the officer who wrote each ticket.
- [boston_pd_citations_with_names_2011_2020.csv](https://wokewindows-data.s3.amazonaws.com/boston_pd_citations_with_names_2011_2020.csv) &mdash; citations in CSV format (82MB)
- [boston_pd_citations_with_names_2011_2020.xlsx](https://wokewindows-data.s3.amazonaws.com/boston_pd_citations_with_names_2011_2020.xlsx) &mdash; citations in Excel format (46MB)

## What does this code do?
This script takes as input:
- [a flat file (TSV) from MassDOT of all traffic citations written by Boston Police from 2011 to 2020](https://www.wokewindows.org/data_sources/2011_2020_citations)
- [2020 roster of Boston Police officers](https://www.wokewindows.org/data_sources/alpha_listing_20200715)
- [2016 roster of Boston Police officers](https://www.wokewindows.org/data_sources/alpha_listing)

The dataset provided by MassDOT gives the ID of the officer who wrote the ticket, but it does not provide the officer's name. This script joins rosters from the Boston Police Department with the citation dataset. The final output is a file that augments the MassDOT data with the name of the officer who wrote each ticket.

## RUNNING
The only requirement for running this project is a working install of [Docker](https://www.docker.com/). All other dependencies are installed as specified in the [Dockerfile](Dockerfile).

NOTE: LibreOffice (through [unoconv](https://github.com/unoconv/unoconv)) is used to generate the XLSX file. If unoconv fails, it may be because you need to allocate more memory to docker; 4GB worked for me.

```
$ docker build -t boston_pd_citations .
...
$ docker run --rm --env-file env.list -v `pwd`:/volume -ti boston_pd_citations sh
/volume # make clean && make all # generated files are stored in output/
/volume # make deploy # upload files to S3
```

## LICENSE
This project is released under the MIT License.
