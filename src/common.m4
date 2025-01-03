m4_dnl
m4_dnl The following makes M4 suppress all output till the next diversion.
m4_dnl
m4_divert(-1)

m4_dnl Disable the commenting feature entirely - it interferes with
m4_dnl the "#" character used in HTML.
m4_changecom

m4_dnl Flag this file's inclusion.
m4_define( `m4_common_included', `true')

m4_dnl The current year, unless it is overridden.
m4_define(
  `m4_current_year',
  m4_esyscmd(
    `CURR_YEAR=${CURR_YEAR:-$(date "+%Y")} && echo -n "${CURR_YEAR}"'
  )`m4_dnl'
)

m4_dnl Change the quoting characters.
m4_dnl (We need single quotes with HTML/JavaScript.)
m4_changequote([[,]])

m4_dnl Create a heading.
m4_dnl   param_1 = <heading-level>
m4_dnl   param_2 = <heading-identifier>
m4_dnl   param_3 = <heading-title>
m4_define(
  [[m4_heading]],
  [[
    m4_ifelse(
      m4_inside_toc,
      `true',
      <tr><td class="toc_entry_$1"><a href="#$2">$3</a></td></tr>,
      <h$1 id="$2">$3</h$1>
    )
  ]]
)

m4_dnl The canonical URL for the current file.
m4_define(
  [[m4_canonical_url]],
  [[m4_esyscmd( `canonical.sh' m4___input_file__)]]m4_dnl
)

m4_dnl Create a table of contents.
m4_define(
  [[m4_toc]],
  [[
    m4_define( `m4_inside_toc', `true')
    <table class="toc">
      <tr><th class="toc_title">Contents</th></tr>
      m4_esyscmd( `grep m4_heading' m4___file__)
    </table>
    m4_define( `m4_inside_toc', `false')
  ]]
)

m4_dnl Create a book-display, along with affiliate links.
m4_dnl   param_1 = <Amazon.com ASIN>, "_dummy_" to skip.
m4_dnl   param_2 = <Amazon.in ASIN>, "_dummy_" to skip.
m4_define(
  [[m4_display_book]],
  [[
    <div class="book_display">
    <img src="m4_post_id.jpg" alt="Cover of m4_post_title.">
    m4_ifelse(
      $1,
      _dummy_,
      `',
      <br>
      <a href="https://www.amazon.com/gp/product/$1?ie=UTF8&amp;tag=rmathew-20&amp;linkCode=as2&amp;camp=1789&amp;creative=9325&amp;creativeASIN=$1"
	style="text-decoration: none;"><img
	src="m4_root_dir/books/buy_amz_us.gif" width="120" height="28"
	alt="Buy from Amazon.com" style="margin: auto;"></a><img
	src="https://ir-na.amazon-adsystem.com/e/ir?t=rmathew-20&amp;l=as2&amp;o=1&amp;a=$1"
	width="1" height="1" alt="" style="border:none; margin:0px;">
    )
    m4_ifelse(
      $2,
      _dummy_,
      `',
      <br>
      <a href="https://www.amazon.in/gp/product/$2"
	style="text-decoration: none;"><img
	src="m4_root_dir/books/buy_amz_in.gif" width="120" height="28"
	alt="Buy from Amazon.in" style="margin: auto;"></a>
    )
    <br>
    <p style="font-size: 85%;">
    <a href="m4_root_dir/caveats.html#aff">Affiliate Links</a>
    </div>
  ]]
)

m4_dnl Collect all posts from a given year in the right order.
m4_dnl   param_1 = Format (html/xml)
m4_dnl   param_2 = <4-digit year>
m4_define( [[m4_collect_posts]], [[m4_esyscmd( `incposts.sh -$1 $2')]])m4_dnl

m4_dnl Include a post.
m4_dnl   param_1 = <4-digit year>
m4_dnl   param_2 = <post-identifier>
m4_define(
  [[m4_include_post]],
  [[
    m4_define( `m4_post_id', $2)
    m4_include( $1/$2.htm4)
  ]]
)

m4_dnl Create a link to a post.
m4_dnl   param_1 = <post-date as YYYY-MM-DD>
m4_dnl   param_2 = <post-identifier>
m4_dnl   param_3 = <link-text>
m4_define(
  [[m4_make_post_link]],
  [[<a href="m4_root_dir/m4_substr($1, 0, 4)/$2.html">$3</a>]]
)

m4_dnl Post header.
m4_define(
  [[m4_post_header]],
  [[
    m4_ifelse(
      m4_standalone_post,
      `true',
      <h1>[m4_post_date] m4_post_title</h1>,
      <h2 id="m4_post_id">
	m4_ifelse( m4_show_post_date, true, [m4_post_date] )m4_make_post_link( m4_post_date, m4_post_id, `m4_post_title')m4_dnl
      </h2>
    )
  ]]
)

m4_dnl Post beginning.
m4_define(
  [[m4_begin_post]],
  [[
    m4_post_header
    <div class="post">
  ]]
)

m4_dnl Post ending.
m4_define(
  [[m4_end_post]],
  [[
    </div>m4_dnl post
    m4_ifelse(
      m4_standalone_post,
      `true',
	<div class="right_aligned">
	  <b><a
	    href="m4_root_dir/m4_substr( m4_post_date, 0, 4)/index.html">Other
	    Posts from m4_substr( m4_post_date, 0, 4)</a></b>
	</div>
      m4_include( footer.htm4)
    )
  ]]
)

m4_dnl Rest of post beginning.
m4_define(
  [[m4_begin_post_rest]],
  [[
    m4_ifelse(
      m4_standalone_post, true, `',
      <p>m4_make_post_link( m4_post_date, m4_post_id, <b>Read More...</b>)
    )
    m4_ifelse( m4_standalone_post, true, `', `m4_divert(-1)')
  ]]
)

m4_dnl Rest of post ending.
m4_define(
  [[m4_end_post_rest]],
  [[
    m4_ifelse( m4_standalone_post, true, `', `m4_divert(0)')
  ]]
)

m4_dnl Restore quoting characters.
m4_changequote(`,')

m4_dnl Restore normal output.
m4_divert(0)m4_dnl
