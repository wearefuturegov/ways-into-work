// var show_ajax_message = function(type, msg) {
//   $("#flash-message").html('<div id="flash_'+type+'">'+msg+'</div>');
// };

// $(function(){
//   $.ajaxSetup({
//     beforeSend: function( xhr ) {
//       var token = $('meta[name="csrf-token"]').attr('content');
//       if (token) xhr.setRequestHeader('X-CSRF-Token', token);
//     }
//   });
// });

$(document).ready(function() {

  $('.nav-toggle').mobileNav();

  $(".legal_pages.eligibility").checkAccepted();

  $('.delete').hideDelete();

  $(".validate").validate();

  $("form").handleFormElements();

});
