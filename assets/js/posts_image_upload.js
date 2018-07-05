const handleFileSelect = evt => {
  evt.stopPropagation();
  evt.preventDefault();

  const files = evt.dataTransfer.files;

  Object.keys(files).forEach(i => {
    const file = files[i];
    const reader = new FileReader();

    reader.onloadend = () => {
      sendData(reader.result, file.type);
    };

    if (file.size > 10000000) {
      alert("The file size must be smaller than 10mb.");
    } else {
      if (isImage(file)) {
        reader.readAsArrayBuffer(file);
      } else {
        alert("The file must be an image.");
      }
    }
  });
};

const sendData = (data, mime) => {
  const XHR = new XMLHttpRequest();
  const url = "/images/binary";

  XHR.onloadend = () => {
    const postTextArea = document.getElementById("post-textarea");
    const markdownImage = "![image](/images/" + XHR.response + ")";
    insertTextAtPos(postTextArea, markdownImage);
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
  if (document.getElementById("post-textarea")) {
    var postTextArea = document.getElementById("post-textarea");
    postTextArea.addEventListener("dragover", handleDragOver, false);
    postTextArea.addEventListener("drop", handleFileSelect, false);
  }
};

const isImage = file =>
  file.type == "image/bmp" ||
  file.type == "image/png" ||
  file.type == "image/jpeg";

const insertTextAtPos = (element, newText) => {
  const start = element.selectionStart;
  const end = element.selectionEnd;
  const text = element.value;
  const before = text.substring(0, start);
  const after = text.substring(end, text.length);
  element.value = before + newText + after;
  element.selectionStart = element.selectionEnd = start + newText.length;
  element.focus();
};
