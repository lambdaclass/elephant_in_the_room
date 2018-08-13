const CSRFToken = document.querySelector("meta[name='csrf-token']").getAttribute('content');
const submitButton = document.getElementsByClassName("feedback-submit").item(0);
const feedbackForm = document.getElementsByClassName("feedback-form-body").item(0);

const handleFeedbackSubmit = csrfToken => event => {
  if (event.target && event.target.className.includes("feedback-submit")) {
    event.stopPropagation();
    event.preventDefault();
    const feedbackTextField = document.getElementsByClassName("feedback-text").item(0);
    const feedbackEmailField = document.getElementsByClassName("feedback-email").item(0);
    const feedbackText = feedbackTextField.value;
    const feedbackEmail = feedbackEmailField.value;
    const XHR = new XMLHttpRequest();

    XHR.onloadend = () => {
      feedbackForm.innerHTML = XHR.response;
    };

    XHR.open("POST", "/feedback");
    XHR.setRequestHeader("X-CSRF-Token", csrfToken);
    XHR.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    XHR.send("text="+feedbackText+"&email="+feedbackEmail);
  }
};

feedbackForm.addEventListener("click", event => handleFeedbackSubmit(CSRFToken)(event));
