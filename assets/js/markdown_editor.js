import InscrybMDE from "inscrybmde"

document.addEventListener("DOMContentLoaded", function() {
  let enable_markdown_editor = function(id) {
    let element = document.getElementById(id)
    if(element) {
      window.editor = new InscrybMDE({
        element: element,
        spellChecker: false
      });
    }
  };
  enable_markdown_editor("post_content");
  enable_markdown_editor("ad_content");
});
