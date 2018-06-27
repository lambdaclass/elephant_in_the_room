import $ from 'jquery';

$(function() {
  $("nav").on("show", function() {
    $(".more-icon").toggle();
  });
  $("nav").on("hide", function() {
    $(".more-icon").toggle();
  });
});
