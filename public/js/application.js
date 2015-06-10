$(document).ready(function() {
  // This is called after the document has loaded in its entirety
  // This guarantees that any elements we bind to will exist on the page
  // when we try to bind to them

  // See: http://docs.jquery.com/Tutorials:Introducing_$(document).ready()
  // debugger;
  $("form").submit(function(e){

    $("form").hide();
    $("div.container").append("<p><img src='/js/ajax-loader.gif'/>Tweeting to Pinpin's little bird...</p>");
    e.preventDefault();
    $.ajax({
      type: "post",
      url: "/tweet",
      success: function(){
        $("p").remove();
        // console.log("yeah");
        $("div.container").append("<p>Tweeted to Pinpin's little bird!</p>")
      },
      error: function(){
        $("p").remove();
        // console.log("buuuu");
        $("div.container").append("<p>Tweet to Pinpin's little bird failed!</p>")
      },
    });
  });
});
