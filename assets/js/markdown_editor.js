import InscrybMDE from "inscrybmde"

document.addEventListener("DOMContentLoaded", function() {
  window.editor = new InscrybMDE({
    element: document.getElementById("post_content"),
    spellChecker: false
  });
});
