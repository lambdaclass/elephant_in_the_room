import $ from "jquery";

$(() => {
  $("post-edit-content").on("dragover", event => {
    event.preventDefault();
    event.stopPropagation();
    $(this).addClass("dragging");
  });

  $("post-edit-content").on("dragleave", event => {
    event.preventDefault();
    event.stopPropagation();
    $(this).removeClass("dragging");
  });

  $(".post-edit-content").on("drop", event => {
    event.preventDefault();
    event.stopPropagation();
    alert("Dropped!");
  });
});
