import $ from 'jquery';

$(function() {
  $(".article-content p img+img").each(function() {
    var left_sibling = $(this.previousSibling);
    if(left_sibling.is(".img-left, .img-right")) {
      return;
    }
    if(left_sibling.is("img")) {
      left_sibling.addClass("img-left");
      $(this).addClass("img-right");
    }
  });
});
