

 async function SendData(data,cb) {
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
        if (xhr.readyState == XMLHttpRequest.DONE) {
            if (cb) {
                cb(xhr.responseText)
            }
        }
    }
    xhr.open("POST", 'https://renzu_jobcenter/nuicb', true)
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.send(JSON.stringify(data))
}

let getEl = function( id ) { return document.getElementById( id )}

window.addEventListener('message', function (table) {
    let event = table.data;
    if (event.close) {
        getEl('spawncontainer').style.display = 'none'
    }
    if (event.jobs) {
        getEl('spawncontainer').style.display = 'flex'
        getEl('spawn').innerHTML = ''
        for (const i in event.jobs) {
            let data = event.jobs[i]
            let ui = `<div class="card">
            <div class="card-img" style="background:url(/web/images/${data.name}.png);background-size: cover;" onclick="select('${data.name}')">
            </div>
            <div class="card-title">
                <h2>${data.label}</h2>
            </div>
            <div class="card-text">
                <p>Info: ${data.info}</p>
            </div>
            <button type="button" class="card-btn" onclick="select('${data.name}')">Select Job</button>
        </div>`
        getEl('spawn').insertAdjacentHTML("beforeend", ui)
        }
    }
})

function select(name,label) {
    SendData({msg : 'select', name : name, label : label})
    SendData({msg: 'close'})
    getEl('spawncontainer').style.display = 'none'
}


document.onkeyup = function (data) {
    if (data.keyCode == '27') {
        SendData({msg: 'close'})
        getEl('spawncontainer').style.display = 'none'
    }
    if (data.keyCode == '121') {
        SendData({msg: 'close'})
        getEl('spawncontainer').style.display = 'none'
    }
}