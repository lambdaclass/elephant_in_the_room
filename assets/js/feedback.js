
const submitButton = document.getElementsByClassName("feedback-submit").item(0);
const feedbackTextField = document.getElementsByClassName("feedback-text").item(0);
const feedbackEmailField = document.getElementsByClassName("feedback-email").item(0);

console.log(submitButton);

const handleFeedbackSubmit = event => {
  event.preventDefault();
  feedbackText = feedbackTextField.value;
  feedbackEmail = feedbackEmailField.value;
  data = {"text": feedbackText, "email": feedbackEmail};
  const XHR = new XMLHttpRequest();
  XHR.open("POST", "/feedback");
  XHR.setRequestHeader("application/x-www-form-urlencoded");
  XHR.send(data)
};

submitButton.onclick = handleFeedbackSubmit;
