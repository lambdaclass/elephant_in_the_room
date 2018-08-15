import $ from 'jquery';

$(() => {
  $('nav').on('show', () => {
    $('.more-icon').toggle();
  });
  $('nav').on('hide', () => {
    $('.more-icon').toggle();
  });
});
