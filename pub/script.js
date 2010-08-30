/*
  The style-sheet initially defines "hidden" to be visible - the following
  function then hides such elements. Otherwise there would be no way to
  show hidden elements if JavaScript is disabled.
*/
function hideHiddenDivs( )
{
  if( document.getElementById)
  {
    document.write(
      '<style type="text/css"> div.hidden { display: none; } </style>');
  }
}


/*
  Hide a shown element and show a hidden element.
*/
function toggleDisplay( elt)
{
  if( document.getElementById)
  {
    if( elt.className == "hidden")
    {
      elt.className = "shown";
    }
    else
    {
      elt.className = "hidden";
    }
  }
}


/*
  Toggles between "Read More..." and "Show Summary Only" mode.
*/
function toggleRestOfPost( postId)
{
  var restOfPostId = postId + "_rest_of_post";
  var readMoreId = postId + "_read_more";
  var readLessId = postId + "_read_less";

  toggleDisplay( document.getElementById( restOfPostId));
  toggleDisplay( document.getElementById( readMoreId));
  toggleDisplay( document.getElementById( readLessId));
}
