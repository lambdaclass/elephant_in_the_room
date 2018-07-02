import $ from "jquery";

$(() => {
  $(".post-edit-content").on("dragover", event => {
    event.preventDefault();
    event.stopPropagation();
    $(this).addClass("dragging");
  });

  $(".post-edit-content").on("dragleave", event => {
    event.preventDefault();
    event.stopPropagation();
    $(this).removeClass("dragging");
  });

  $(".post-edit-content").on("drop", event => {
    event.preventDefault();
    event.stopPropagation();
    readfile(event.data);
  });
});

readfile = file => {
  var formData = new FormData();

  formData.append("file", file);

  $.ajax({
    url: "./path_to_file_handler.php",
    type: "POST",
    data: formData,
    async: true,
    success: data => {
      console.log(data);
    },
    cache: false,
    contentType: false,
    processData: false
  });
};
