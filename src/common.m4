m4_dnl
m4_dnl The following makes M4 suppress all output till the next diversion.
m4_dnl
m4_divert(-1)

m4_dnl Disable the commenting feature entirely - it interferes with
m4_dnl the "#" character used in HTML.
m4_changecom

m4_dnl Flag this file's inclusion.
m4_define( `m4_common_included', `true')

m4_dnl Change the quoting characters.
m4_dnl (We need single quotes with HTML/JavaScript.)
m4_changequote([[,]])

m4_dnl Create a heading.
m4_dnl   arg1 = <heading-level>
m4_dnl   arg2 = <heading-identifier>
m4_dnl   arg3 = <heading-title>
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
m4_dnl   arg1 = <Amazon.com ASIN>
m4_dnl   arg2 = <Flipkart.com id>
m4_define(
  [[m4_display_book]],
  [[
    <div class="book_display">
    <img src="m4_root_dir/books/images/m4_post_id.jpg" alt="m4_post_title">
    m4_ifelse(
      $1,
      _dummy_,
      `',
      <br>
      <a href="http://www.amazon.com/gp/product/$1?ie=UTF8&amp;tag=rmathew-20&amp;linkCode=as2&amp;camp=1789&amp;creative=9325&amp;creativeASIN=$1">
      <img src="m4_root_dir/books/images/buyamz.gif" alt="Buy from Amazon.com">
      </a>
      <img src="http://www.assoc-amazon.com/e/ir?t=rmathew-20&amp;l=as2&amp;o=1&amp;a=$1" width="1" height="1" alt="" style="border:none; margin:0px;">
    )
    m4_ifelse(
      $2,
      _dummy_,
      `',
      <br>
      <a href="http://www.flipkart.com/books/$2?affid=INRanjit">
      <img src="m4_root_dir/books/images/buyfkart.png" alt="Buy from Flipkart.com">
      </a>
    )
    </div>
  ]]
)

m4_dnl Collect all posts from a given year in the right order.
m4_dnl   arg1 = Format (html/xml)
m4_dnl   arg2 = <4-digit year>
m4_define( [[m4_collect_posts]], [[m4_esyscmd( `incposts.sh -$1 $2')]])m4_dnl

m4_dnl Include a post.
m4_dnl   arg1 = <4-digit year>
m4_dnl   arg2 = <post-identifier>
m4_define(
  [[m4_include_post]],
  [[
    m4_define( `m4_post_id', $2)
    m4_include( $1/$2.htm4)
  ]]
)

m4_dnl Create a link to a post.
m4_dnl   arg1 = <post-date as YYYY-MM-DD>
m4_dnl   arg2 = <post-identifier>
m4_dnl   arg3 = <link-text>
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
      <div id="m4_post_id" class="post_header">
	<p>
	<b>
	m4_ifelse( m4_show_post_date, true, [m4_post_date] )m4_make_post_link( m4_post_date, m4_post_id, `m4_post_title')m4_dnl
	</b>
      </div>
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
      <br class="post_footer">
    </div>
    m4_ifelse(
      m4_standalone_post,
      `true',
        <table style="border: 0px; margin-left: auto; margin-right: auto;">
        <tr style="border: 0px;">
        <td style="border: 0px;">
	  <div id="fb-root"></div>
	  <fb:like href="" send="false" layout="button_count" width="110"
	    show_faces="false" font=""></fb:like>
        </td>
        <td style="border: 0px;">
	  <a href="http://twitter.com/share" class="twitter-share-button"
	    data-count="horizontal" data-via="rmathew4tw">Tweet</a>
        </td>
        <td style="border: 0px;">
	  <g:plusone size="medium"></g:plusone>
        </td>
        <td style="border: 0px;">
	  <script type="text/javascript" src="http://www.reddit.com/static/button/button1.js"></script>
        </td>
        </tr>
        </table>
	<div class="right_justified">
	  <b><a
	    href="m4_root_dir/m4_substr( m4_post_date, 0, 4)/index.html">Other
	    Posts from m4_substr( m4_post_date, 0, 4)</a></b>
	</div>
      </div>
      <script src="http://connect.facebook.net/en_US/all.js#xfbml=1"></script>
      <script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script>
      <script type="text/javascript" src="https://apis.google.com/js/plusone.js"></script>
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
