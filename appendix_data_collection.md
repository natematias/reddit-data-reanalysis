Download all submissions:
```bash
mkdir -p data/reddit_data
cd data/reddit_data
wget http://files.pushshift.io/reddit/submissions/RS_2006-01.bz2
```

Download all posts:
```bash
wget http://files.pushshift.io/reddit/comments/RC_2007-10.bz2
```
Extract subset of relevant data for analysis for submissions:
```bash
cd ../../
mkdir extracted_data
bzip2 -dck data/reddit_data/RS_2006-01.bz2 | jq '. | [(.created_utc | tostring), .subreddit, "t3_"+.id] | join(",")' | tr -d '"' | sort -t, -k2 >> extracted_data/submission_sparse.csv
```

GENERATING PROCEDURE FOR REDDIT COMMENTS:
```bash
bzip2 -dck data/reddit_data/RC_2007-10.bz2 | jq '. | [(.created_utc | tostring), .subreddit, "t1_"+.id, .parent_id] | join(",")' | tr -d '"' | sort -t, -k2 >> extracted_data/comment_sparse-RC_2007-10.csv
```

We then must convert all base 36 IDs into base 10 numbers for later steps. We first define a file called strtonum_bases.awk, which quickly does the conversion:

```bash
#!/usr/bin/awk -f
function strtonumbases(str, base, i, len, character, pos, result, negative) {
    base = base + 0
    result = 0
    sub(/^ */, "", str)
    negative = str ~ /^-/ ? -1 : 1
    sub(/^[\-+]/, negative, str)
    if (!base) {
        base = 10
        if (str ~ /^0/) {
            base = 8
        }
        if (str ~ /^0[xX]/) {
            base = 16
        }
    }
    if (base == 16) {
        sub(/^0[xX]/, "", str)
    }
    if (base == 10) {
        return str + 0
    }
    len = length(str)
    for (i = 1; i <= len; i++) {
        character = toupper(substr(str, i, 1))
        pos = index("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", character) - 1
        if (pos != -1 && pos <= base) {
            result = result * base + pos
        }
        else {
            return result
        }
    }
    return result * negative
}

{
print strtonumbases($1, 36)
}
```

Then, we process all files:

```bash
awk -F "\"*,\"*" '{print $3}' extracted_data/submission_sparse.csv | gawk '{print gensub(/t3_/, "", $1)}' | awk -f strtonum_bases.awk > extracted_data/all_submissions_base_10.csv
awk -F "\"*,\"*" '{print $3}' extracted_data/comment_sparse-RC_2007-10.csv | gawk '{print gensub(/t1_/, "", $1)}' | awk -f strtonum_bases.awk > extracted_data/all_comments_base_10-RC_2007-10.csv
```


