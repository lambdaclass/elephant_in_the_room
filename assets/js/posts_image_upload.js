const handleFileSelect = evt => {
  evt.stopPropagation();
  evt.preventDefault();

  var files = evt.dataTransfer.files;

  var reader = new FileReader();

  reader.onloadend = () => {
    sendData(reader.result, files[0].type);
  };

  reader.readAsArrayBuffer(files[0]);
};

const sendData = (data, mime) => {
  var XHR = new XMLHttpRequest();
  const url = "http://localhost:4000/images/binary";

  XHR.open("POST", url);

  XHR.setRequestHeader("Content-Type", mime);

  XHR.send(data);
};

const handleDragOver = evt => {
  evt.stopPropagation();
  evt.preventDefault();
  evt.dataTransfer.dropEffect = "copy";
};

window.onload = () => {
  var postTextArea = document.getElementById("post-textarea");

  postTextArea.addEventListener("dragover", handleDragOver, false);
  postTextArea.addEventListener("drop", handleFileSelect, false);
};
