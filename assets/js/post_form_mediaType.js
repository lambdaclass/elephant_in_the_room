
const postType = document.getElementsByClassName("post-form-type").item(0)
const mediaInput = document.getElementsByClassName("post-media-input").item(0)

console.log(postType)


postType.onchange = event => 
    console.log(event)
