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

Then, we process all files and convert the base 36 IDs to base 10:

```bash
awk -F "\"*,\"*" '{print $3}' extracted_data/submission_sparse.csv | gawk '{print gensub(/t3_/, "", $1)}' | awk -f strtonum_bases.awk > extracted_data/all_submissions_base_10.csv
awk -F "\"*,\"*" '{print $3}' extracted_data/comment_sparse-RC_2007-10.csv | gawk '{print gensub(/t1_/, "", $1)}' | awk -f strtonum_bases.awk > extracted_data/all_comments_base_10-RC_2007-10.csv
```

Next, we sort the IDs ascending so that we can sequentially search through them later:

```bash
sort -n extracted_data/all_submissions_base_10.csv > extracted_data/all_submissions_base_10_sorted.csv
sort -n extracted_data/all_comments_base_10-RC_2007-10.csv > extracted_data/all_comments_base_10-RC_2007-10_sorted.csv
```

Now we can being analyzing the dataset for completeness. There are two distinct types of errors that the data may have. Every comment on Reddit has in the metadata a `parent_id` field, which refers to the Post or Comment to which this particular comment is responding. If the dataset is in fact complete, then we would expect every `parent_id` to refer to a Post or Comment that is within the dataset - if it is not, then by this process we have identified missing content. These are "known unknowns", or Posts and Comments that we have identified as being proven to be missing from the corpus. To detect these, we walk through every comment in the dataset, select the `parent_id` from the comment, and then query in memory to a Redis database to see if the `parent_id` is known to exist within the database. If the lookup returns a nil value, then we know that a comment refers to a comment or post that is not present in the dataset. We then store a record of this missing data in a MongoDB database for later reporting purposes.

The next group is the "unknown unknowns" - data that still may be missing from the corpus, but don't have any evident references to those. To find these, we have to employ the same analysis Baumgartner used to generate the data. We use the base 10 files to find missing gaps. Since we have sorted the base ten files, we know that anything missing between two sequential numbers is a potentially missing Post or Comment. The first Comment ID in the Baumgartner dataset is #1 and the first Post ID is #99700002. 

The high post beginning ID has been explained as a skip in the space. It may be that for some internal reason, the IDs 1-99700001 was intentionally skipped by Reddit engineers. This seems at odds with a quick qualitative look through the data. For instance, the first known Post in the Baumgartner set is 99700002, though earlier comments such as the base 36 "87" (295), "1000" (46656), "2000" (93312), "9000" (419904), and "18000" (2052864) have all yielded valid documents. As of writing, a request has been filed to Baumgartner to also collect this data. For now, we will limit our analysis to IDs inclusive of the range of known Posts and Comments within the Baumgartner dataset, though there are potentially substantial missing posts from the earliest moments of Reddit's existence.

To detect the "unknown unknowns" within the ID space of the Baumgartner dataset, we simply walk through every known base 10 id, then detect gaps within the space. When the next number is read, we store the range as both base 10 and base 36 into a MongoDB database, so that we generate records of each gap.

The detection of known unknowns and unknown unknowns is a bit more complicated than the initial transformations of the data. For this reason we employ a series of scripts in Ruby that employ Sidekiq, a memory queue task processor, which ensures highly parallel consumption of the tasks at hand. The code for this is located in the data_collection/code/ folder and is lightly documented to reflect the work involved. To run the tasks, there are a few rake commands:

```bash
rake store_in_memory
rake check_known_unknowns
rake check_unknown_unknowns
```