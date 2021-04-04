#!/usr/bin/awk -f
# Emits an HTML-snippet corresponding to an activity-calendar of blog-posts in
# reverse chronological order.

# Returns the background-color for a cell given the number of blog-posts.
func get_background_color(num_posts) {
    # Inspired by the color-scheme in the GitLab activity-calendar.
    if (num_posts == 0) {
        return "rgb(224, 224, 224)"
    } else if (num_posts == 1) {
        return "rgb(172, 213, 242)"
    } else if (num_posts <= 4) {
        return "rgb(127, 168, 201)"
    } else if (num_posts <= 8) {
        return "rgb(82, 123, 160)"
    } else {
        return "rgb(37, 78, 119)"
    }
}

BEGIN {
    FIRST_YEAR = 2001
    CURR_YEAR = int(strftime("%Y"))
    if (!FINAL_YEAR) {
    	FINAL_YEAR = CURR_YEAR""  # Appending "" force-converts to string.
    }
    LAST_YEAR = int(FINAL_YEAR)
    if (LAST_YEAR < FIRST_YEAR || LAST_YEAR > CURR_YEAR) {
    	printf("ERROR: Invalid year %d - must be in the range %d-%d.\n",
    	       LAST_YEAR, FIRST_YEAR, CURR_YEAR)
    	exit 1
    }
}

# Match input-lines of the form "N 20YY-MM" to record monthly posts-frequency.
/^[0-9]+ 20[0-9][0-9]-[0,1][0-9]$/ { freqs[$2] = $1; }

END {
    print "<table style=\"margin: 8px auto; border-collapse: separate; border-spacing: 4px; border: 0;\">"

    printf("<thead><tr><th style=\"width: 3.5em;\"></th>")
    split("Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec", MONTHS, " ")
    for (month = 1; month <= 12; month++) {
        printf("<th style=\"width: 2.5em;\">%s</th>", MONTHS[month])
    }
    printf("</tr></thead>\n<tbody>\n")
    for (year = LAST_YEAR; year >= FIRST_YEAR; year--) {
        print "<tr><th style=\"text-align: right;\">"
        printf("<a href=\"m4_root_dir/%d/index.html\">%d</a></th>", year, year)
        for (month = 1; month <= 12; month++) {
            key = sprintf("%d-%02d", year, month)
            num_posts = 0
            if (key in freqs) {
                num_posts = int(freqs[key])
            }
            printf("<td style=\"background-color: %s;\" title=\"%d post(s) in %s %d\">&nbsp;</td>",
                   get_background_color(num_posts), num_posts, MONTHS[month],
                   year)
        }
        printf("</tr>\n")
    }
    print "</tbody><tfoot>"
    print "<tr><td colspan=\"13\" style=\"height: 8px;\"></td></tr>"
    print "<tr><th colspan=\"8\" style=\"text-align: right;\">Legend:</th>"
    printf("<td style=\"background-color: %s;\" title=\"No posts\">&nbsp;</td>",
           get_background_color(0))
    printf("<td style=\"background-color: %s;\" title=\"One post\">&nbsp;</td>",
           get_background_color(1))
    printf("<td style=\"background-color: %s;\" title=\"2-4 posts\">&nbsp;</td>",
           get_background_color(4))
    printf("<td style=\"background-color: %s;\" title=\"5-8 posts\">&nbsp;</td>",
           get_background_color(8))
    printf("<td style=\"background-color: %s;\" title=\"9 or more posts\">&nbsp;</td>",
           get_background_color(16))
    print "</tr></tfoot></table>"
}
