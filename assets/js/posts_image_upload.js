const handleFileSelect = (editor, evt) => {
  evt.stopPropagation();
  evt.preventDefault();

  const files = evt.dataTransfer.files;

  Object.keys(files).forEach(i => {
    const file = files[i];
    const reader = new FileReader();

    reader.onloadend = () => {
      sendData(reader.result, file.type);
    };

    if (file.size > 8000000) {
      alert("The file size must be smaller than 8mb.");
    } else {
      if (isImage(file)) {
        reader.readAsArrayBuffer(file);
      } else {
        alert("The file must be an image smaller than 8mb.");
      }
    }
  });
};

const sendData = (data, mime) => {
  const XHR = new XMLHttpRequest();
  const url = "/images/binary";

  XHR.onloadend = () => {
    if (XHR.status == 202) {
      const markdownImage = "![image](/images/" + XHR.response + ")";
      window.editor.codemirror.replaceSelection(markdownImage);
    } else {
      alert(XHR.response);
    }
  };

  XHR.open("POST", url);

  XHR.setRequestHeader("Content-Type", mime);

  XHR.send(data);
};

const handleDragOver = (editor, evt) => {
  evt.stopPropagation();
  evt.preventDefault();
  evt.dataTransfer.dropEffect = "copy";
};

window.onload = () => {
  if (window.editor) {
    var postTextArea = window.editor.codemirror;
    postTextArea.on("dragover", handleDragOver, false);
    postTextArea.on("drop", handleFileSelect, false);
  }
};

const isImage = file =>
  file.type == "image/bmp" ||
  file.type == "image/png" ||
  file.type == "image/jpeg" ||
  file.type == "image/jpg";
