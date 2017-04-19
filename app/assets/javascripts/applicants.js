var scrollToPosition = function(position, callback) {
    $('html, body').stop().animate({ scrollTop: position - 100}, 1000, function() {
        if (callback !== undefined) {
            callback();
        }
    });
}

var scrollToTag = function(elementTag, callback) {
    var new_position = $(elementTag).offset().top;
    scrollToPosition(new_position, callback)
}

var toggleDisableButton = function(changeElement, submitButton) {
    // set default to disabled
    $(submitButton).prop('value', 'Please click the checkbox above');
    $(submitButton).prop('disabled', true);

    $(changeElement).change(function() {
        if($(this).is(":checked")) {
            $(submitButton).prop('value', 'Submit');
            $(submitButton).prop('disabled', false);
        } else {
            $(submitButton).prop('value', 'Please click the checkbox above');
            $(submitButton).prop('disabled', true);
        }
    });
}

function ready() {
    $('#apply-now').click(function(e) {
        e.preventDefault();
        scrollToPosition(100, function() {
            $('#applicant_first_name').focus();
        });
    })

    $('#learn-more').click(function(e) {
        e.preventDefault();
        scrollToTag('#positions-top')
    });

    toggleDisableButton('#background-check-consent-checkbox', '#background-check-consent-submit');
}

$(document).on("ready page:load", ready);