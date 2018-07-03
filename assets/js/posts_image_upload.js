import $ from "jquery";

$(() => {
  $(".post-edit-content").on("dragover", event => {
    event.preventDefault();
    $(this).addClass("dragging");
  });

  $(".post-edit-content").on("dragleave", event => {
    event.preventDefault();
    $(this).removeClass("dragging");
  });

  $(".post-edit-content").on("drop", event => {
    event.preventDefault();
    event.stopPropagation();
    readfile(event.originalEvent);
  });
});

const readfile = event => {
  const imageUrl = event.dataTransfer.getData("text/html");
  const rex = /src="?([^"\s]+)"?\s*/;

  const url = rex.exec(imageUrl);

  $.ajax({
    url: "localhost:4000/images",
    type: "post",
    data: encodeURIComponent("url=" + url[1]),
    async: true,
    success: data => {
      console.log(data);
    },
    contentType: "application/x-www-form-urlencoded"
  });
};
