import $ from 'jquery';

$(() => {
  $('.article-content p img+img').each(function () {
    const leftSibling = $(this.previousSibling);
    if (leftSibling.is('.img-left, .img-right')) {
      return;
    }
    if (leftSibling.is('img')) {
      leftSibling.addClass('img-left');
      $(this).addClass('img-right');
    }
  });
});
