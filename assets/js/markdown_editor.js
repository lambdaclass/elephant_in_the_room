import InscrybMDE from 'inscrybmde';

document.addEventListener('DOMContentLoaded', () => {
  const enableMarkdownEditor = function (id) {
    const element = document.getElementById(id);
    if (element) {
      window.editor = new InscrybMDE({
        element,
        spellChecker: false,
      });
    }
  };
  enableMarkdownEditor('post_content');
  enableMarkdownEditor('ad_content');
});
