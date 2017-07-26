==Tasks

Use the rake task `download_all` to download the Baumgartner dataset into the following directory structure (note that config.yml file must be present with `download_path` specified, otherwise will default to ../data):
```
├── comments
│   ├── 2005
│   │   └── RC_2005-12.bz2
│   ├── 2006
│   │   ├── RC_2006-01.bz2
│   │   ├── RC_2006-02.bz2
..........................
..........................
..........................
..........................
│       ├── RC_2017-03.bz2
│       ├── RC_2017-04.bz2
│       ├── RC_2017-05.bz2
│       └── RC_2017-06.bz2
├── submissions
│   ├── 2006
│   │   ├── RS_2006-01.bz2
│   │   ├── RS_2006-02.bz2
..........................
..........................
..........................
..........................
│       ├── RS_2017-03.bz2
│       ├── RS_2017-04.bz2
│       ├── RS_2017-05.bz2
│       └── RS_2017-06.bz2
```