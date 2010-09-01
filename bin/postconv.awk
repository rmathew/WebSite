# AWK script to convert a post so that it can be included in the site feed.

/m4_end_post/ { emit = "false" }

# NOTE: Uncomment the following for summarised feed.
#
# /m4_post_date/ {
#   year_ind = match( $0, /[0-9][0-9][0-9][0-9]/)
#   post_year = substr( $0, year_ind, 4)
# }
#
# /m4_begin_post_rest/ {
#   emit = "false"
#   n = split( FILENAME, tmp, "/")
#   split( tmp[n], tmp, ".")
#   post_id = tmp[1]
#   printf "&lt;p&gt;\n"
#   printf "&lt;a href=\"http://rmathew.com/%s/%s.html\"&gt;&lt;b&gt;Read More...&lt;/b&gt;&lt;/a&gt;\n", post_year, post_id
# }

{
  if (emit == "true" && NF > 0) {
    line = $0

    # NOTE: Remove the following condition for summarised feed.
    if (line != "m4_begin_post_rest" && line != "m4_end_post_rest") {
      print line
    }
  }
}

/m4_begin_post$/ { emit = "true" }
