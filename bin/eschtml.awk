# AWK script to escape HTML content in the site feed to create valid XML.

/<\/content>/ { escape = "false" }

{
  line = $0
  if (escape == "true" && NF > 0) {
    gsub( /&/, "\\&amp;", line)
    gsub( /"/, "\\&quot;", line)
    gsub( /</, "\\&lt;", line)
    gsub( />/, "\\&gt;", line)
  }

  print line
}

/<content type="html">$/ { escape = "true" }
