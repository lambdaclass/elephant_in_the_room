import InscrybMDE from "inscrybmde"

document.addEventListener("DOMContentLoaded", function() {
  if(document.getElementById("post_content")) {
    window.editor = new InscrybMDE({
      element: document.getElementById("post_content"),
      spellChecker: false
    });
  }
});
