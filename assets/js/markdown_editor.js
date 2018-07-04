import InscrybMDE from "inscrybmde"

document.addEventListener("DOMContentLoaded", function() {
  new InscrybMDE({
    element: document.getElementById("post_content"),
    spellChecker: false
  });
});
