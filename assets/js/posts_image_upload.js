const handleFileSelect = evt => {
  evt.stopPropagation();
  evt.preventDefault();

  var files = evt.dataTransfer.files;
  var type;
  var reader = new FileReader();

  reader.onloadend = () => {
    sendData(reader.result, type);
  };

  for (var i = 0, file; (file = files[i]); i++) {
    type = file.type;

    reader.readAsArrayBuffer(file);
  }
};

const sendData = (data, mime) => {
  var XHR = new XMLHttpRequest();
  const url = "http://localhost:4000/images/binary";

  XHR.onloadend = () => {
    console.log(XHR.response);
  };

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
