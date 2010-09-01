m4_dnl
m4_define( `m4_posttrans_included', `true')m4_dnl
m4_dnl
m4_dnl
m4_dnl Include page header if this is becoming a standalone page.
m4_dnl
m4_ifelse(
  m4_common_included,
  `true',
  `',
  `
    m4_define( `m4_post_id', `m4_regexp( m4___file__, `/\([a-z0-9_]+\)\.htm4', `\1')')m4_dnl
    m4_define( `m4_root_dir', ..)m4_dnl
    m4_define( `m4_page_title', m4_post_title)m4_dnl
    m4_define( `m4_page_section', ``Archives'')m4_dnl
    m4_define( `m4_standalone_post', `true')m4_dnl
m4_include( header.htm4)m4_dnl
    <div id="main-copy">
      m4_define( `m4_show_post_date', `true')m4_dnl
')m4_dnl
