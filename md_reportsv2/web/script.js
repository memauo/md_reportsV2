let playSound = 0
let createType = 0
let resultsHome = {}
let opened = 0
let newMessage = 0
let chatMsgs = {}
let latestMsg = 0
let myname = ''
let lastname = ""
let notified = 0
let noreport = ""
let inclosed = 0
let admin = 0
let manager = 0
window.onload = function() {
    fetch(`https://${GetParentResourceName()}/uiReady`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
    
};
function closeWeb(){
    cont.classList.remove("openAnim")
    cont.classList.add("closeAnim")

    setTimeout(() => {
        cont.style.display = "none"
    }, 200)

    fetch(`https://${GetParentResourceName()}/closeUI`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    })
    if (playSound){
        const click = new Audio("assets/click.mp3");
        click.play();
    }
}
document.addEventListener('keydown', function (e) {
    if (e.key === "Escape") {
        closeWeb()
    }
});
function playClick(){
    if (playSound){
        const click = new Audio("assets/click.mp3");
        click.play();
    }

}


window.addEventListener('message', function(event) {
    const data = event.data;
    if (data.action === "openUi") {
        document.getElementById("cont").style.display = "flex";
        showPage('home')
        newShow(1)
        updateHome()
        cont.classList.remove("closeAnim")
        cont.classList.add("openAnim")
        if (admin==true){
            document.getElementById('dutyBtn').style.display = "flex"
        } else {
            document.getElementById('dutyBtn').style.display = "none"
        }
    }
    if (data.action === "setDef") {
        document.getElementById("servername").innerHTML = data.serverName;
        playSound = data.sound
        trans(data.translate)
    }
    if (data.action=="successCreation"){
        successCreated()
    }
    if (data.action=="updateHomePage"){
        resultsHome = data.result
        fillHome()
    }
    if (data.action=="updatePlayerPage"){
        setPlayerPage(data.result)
    }
    if (data.action=="updateChat"){
        chatMsgs = data.result
        showChat()
    }
    if (data.action === "forceChatUpdate") {
        if (opened == data.id) {
            fetch(`https://${GetParentResourceName()}/chatUpdate`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({opened: opened, newMessage: 1})
            });
        }
    }
    if (data.action=="setopenid"){
        opened = data.idecko
        openPlayerReport(opened, 'active')
        chatUpdate(opened)
    }
    if (data.action=="setname"){
        myname = data.name
    }
    if (data.action=="closedreport"){
        if (data.op == opened){
            showPage('home')
            newShow(1)
            updateHome()
            playClick()
            opened = 0
            const chatBtn = document.querySelectorAll('.navItem')[0];
            if (opened && opened !== 0) {
                chatBtn.classList.remove('disabledBtn');
            } else {
                chatBtn.classList.add('disabledBtn');
            }
        }
    }
    if (data.action=="setGroup"){
        admin = data.group
        if (admin==true){
            document.getElementById('adminSection').style.display = 'flex'
        } else {
            document.getElementById('adminSection').style.display = 'none'
        }
    }
    if (data.action=="setManager"){
        manager = data.group
        if (manager==true){
            document.getElementById('managerSection').style.display = 'flex'
        } else {
            document.getElementById('managerSection').style.display = 'none'
        }
    }
    if (data.action=="updateAdmin"){
        showAdmin(data.result)
        
    }
    if (data.action=="wiped"){
        opened = 0
        closeWeb()
    }
    if (data.action=="updatedMng"){
        updatedMng(data.result)
    }
});


function trans(tr){
    document.getElementById('transReportMenu').innerHTML = tr.ReportMenu
    document.getElementById('transActiveReports').innerHTML = tr.ActiveReports
    document.getElementById('transActiveReports2').innerHTML = tr.ActiveReports
    document.getElementById('transCreateReport').innerHTML = tr.CreateReport
    document.getElementById('transCreateReport2').innerHTML = tr.CreateReport
    document.getElementById('transWaitingReports').innerHTML = tr.WaitingReports
    document.getElementById('transWaitingReports2').innerHTML = tr.WaitingReports
    document.getElementById('transHistory').innerHTML = tr.History
    document.getElementById('report1').innerHTML = tr.Player
    document.getElementById('report2').innerHTML = tr.Bug
    document.getElementById('report3').innerHTML = tr.Other
    document.getElementById('transHeader').innerHTML = tr.Header
    document.getElementById('transInfo').innerHTML = tr.Info
    document.getElementById('transCreateReport3').innerHTML = tr.CreateReport
    document.getElementById('transOpenReport').innerHTML = tr.OpenReport
    noreport = tr.NoReportCreated
    document.getElementById('transStartSolving').innerHTML = tr.StartSolving
    document.getElementById('transGoBack').innerHTML = tr.GoBack
    document.getElementById('transGoTo').innerHTML = tr.GoTo
    document.getElementById('transTranscriptAT').innerHTML = tr.TranscriptAT
    document.getElementById('transMarkAsDone').innerHTML = tr.MarkAsDone


    document.getElementById('transTotalReports').innerHTML = tr.TotalReports
    document.getElementById('SolvedReports').innerHTML = tr.SolvedReports
    document.getElementById('wipebtn').innerHTML = tr.WIPE
    document.getElementById('Irreversible').innerHTML = tr.Irreversible
    document.getElementById('transClosedReports').innerHTML = tr.ClosedReports
    document.getElementById('transAdminActivity').innerHTML = tr.AdminActivity

}


function showPage(i){
    document.getElementById('home').style.display = 'none'
    document.getElementById('new').style.display = 'none'
    document.getElementById('chat').style.display = 'none'
    document.getElementById('admin').style.display = "none"
    document.getElementById('management').style.display = "none"
    document.getElementById(i).style.display = 'block'
    document.getElementById('adminview').style.display = 'none'

    if (i=="chat" && admin==true){
        document.getElementById('adminview').style.display = 'block'
    }
    select('report1')
    document.getElementById('createHead').value = ""
    document.getElementById('createInfo').value = ""
    document.getElementById('delbtnuser').style.display = 'none'
    if (i=="chat" && inclosed==0){
        document.getElementById('delbtnuser').style.display = 'flex'

    }
}



function setActive(el) {
    document.querySelectorAll('.navItem').forEach(item => {
        item.classList.remove('activeNav');
    });

    el.classList.add('activeNav');
}
function newShow(i) {
    document.querySelectorAll('.navItem').forEach(item => {
        item.classList.remove('activeNav');
    });

    const navItems = document.querySelectorAll('.navItem');
    navItems[i].classList.add('activeNav');
}
function select(i){
    document.querySelectorAll('#report1, #report2, #report3')
        .forEach(el => el.classList.remove('activ'));

    document.getElementById(i).classList.add('activ');
    createType = i;
}
function checkOpened(){
    if (opened==0){
        newShow(1);
        showPage('home');
    }
}
function updateNavState(i) {
    const chatBtn = document.querySelectorAll('.navItem')[i];

    if (opened && opened !== 0) {
        chatBtn.classList.remove('disabledBtn');
    } else {
        chatBtn.classList.add('disabledBtn');
    }
}



function createRep(){
    header = document.getElementById('createHead').value;
    info = document.getElementById('createInfo').value;
    type = createType

    fetch(`https://${GetParentResourceName()}/createReport`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({header:header, info:info, type:type})
    })
}
function successCreated(){
    document.getElementById('createHead').value = "";
    document.getElementById('createInfo').value = "";
    fetch(`https://${GetParentResourceName()}/getNewChat`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    })
}

function updateHome(){
    fetch(`https://${GetParentResourceName()}/updateHome`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    })
}

function fillHome() {
    document.getElementById('historyReps').innerHTML = "";
    document.getElementById('activeReps').innerHTML = "";
    document.getElementById('waitingReps').innerHTML = "";

    let hasWaiting = false;
    let hasActive = false;
    let hasHistory = false;

    for (let i = resultsHome.length - 1; i >= 0; i--) {

        if (resultsHome[i].status == "waiting") {
            hasWaiting = true;
            document.getElementById('waitingReps').innerHTML +=
                `<div class="repListCell" onclick="playClick(); openPlayerReport(${resultsHome[i].id}, 'waiting')">
                    <div class="repListCellTick">
                        <i class="fa-solid fa-ticket"></i>
                    </div>
                    <div class="repListCellCont">
                        <div class="repListCellContCell">${resultsHome[i].header}</div>
                        <div class="repListCellContCell">${formatDate(resultsHome[i].date)}</div>
                    </div>
                </div>`;
        }

        else if (resultsHome[i].status == "solving") {
            hasActive = true;
            document.getElementById('activeReps').innerHTML +=
                `<div class="repListCell" onclick="playClick(); openPlayerReport(${resultsHome[i].id}, 'active')">
                    <div class="repListCellTick">
                        <i class="fa-solid fa-ticket"></i>
                    </div>
                    <div class="repListCellCont">
                        <div class="repListCellContCell">${resultsHome[i].header}</div>
                        <div class="repListCellContCell">${formatDate(resultsHome[i].date)}</div>
                    </div>
                </div>`;
        }

        else if (resultsHome[i].status == "closed") {
            hasHistory = true;
            document.getElementById('historyReps').innerHTML +=
                `<div class="repListCell" onclick="playClick(); openPlayerReport(${resultsHome[i].id}, 'closed')">
                    <div class="repListCellTick">
                        <i class="fa-solid fa-ticket"></i>
                    </div>
                    <div class="repListCellCont">
                        <div class="repListCellContCell">${resultsHome[i].header}</div>
                        <div class="repListCellContCell">${formatDate(resultsHome[i].date)}</div>
                    </div>
                </div>`;
        }
    }
    if (!hasWaiting) {
        document.getElementById('waitingReps').innerHTML =
            `<div class="noreport">${noreport}</div>`;
    }

    if (!hasActive) {
        document.getElementById('activeReps').innerHTML =
            `<div class="noreport">${noreport}</div>`;
    }

    if (!hasHistory) {
        document.getElementById('historyReps').innerHTML =
            `<div class="noreport">${noreport}</div>`;
    }
}
function formatDate(value) {
    const d = new Date(value);

    if (isNaN(d.getTime())) return "invalid date";

    const pad = (n) => String(n).padStart(2, "0");

    return `${pad(d.getDate())}.${pad(d.getMonth() + 1)}.${d.getFullYear()} ${pad(d.getHours())}:${pad(d.getMinutes())}`;
}

function formatDate2(value) {
    const d = new Date(value);

    if (isNaN(d.getTime())) return "invalid date";

    const pad = (n) => String(n).padStart(2, "0");

    return `${pad(d.getDate())}.${pad(d.getMonth() + 1)}. ${pad(d.getHours())}:${pad(d.getMinutes())}`;
}


function openPlayerReport(id, st){
    if (id!=-1){
        opened = id
        newMessage = 0
        latestMsg = 0
        chatMsgs = {}
        if (st=="closed"){
            document.getElementById('hideinpt').style.display = 'none'
            inclosed = 1

        } else{
            document.getElementById('hideinpt').style.display = 'flex'
            inclosed = 0

        }
        chatUpdate(opened);
        updateNavState(0)
        fetch(`https://${GetParentResourceName()}/openPlayerReport`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({opened:opened})
        })
    }

}
function setPlayerPage(res){
    showPage("chat")
    newShow(0)
        chatInitialized = false
    latestMsg = 0
    document.getElementById('chatHeader').innerHTML = res.header
    document.getElementById('chatInfo').innerHTML = res.info
    document.getElementById('chatDate').innerHTML = formatDate(res.date)
    if (inclosed==0){
        document.getElementById('delbtnuser').style.display = 'flex'
    }
        

    if (opened==0){
        document.getElementById("ch").style.display = "none"
        document.getElementById("chc").style.display = "block"
    } else{
        document.getElementById("chc").style.display = "none"
        document.getElementById("ch").style.display = "block"
    }
}

function sendChatMsg(){
    let msg = document.getElementById('chatInput').value
    if (msg!=""){
        fetch(`https://${GetParentResourceName()}/sendChatMsg`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({msg:msg, opened:opened})
    })
    document.getElementById('chatInput').value = ""
    chatUpdate(opened)
    }
    
}

function chatUpdate(idd){
    if (opened!=0){
        if (opened==idd){
            fetch(`https://${GetParentResourceName()}/chatUpdate`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({opened:opened, newMessage:newMessage})
            })
        }

    }
}


let chatInitialized = false;
function showChat(){
    const chat = document.getElementById('chatArea')
    chat.innerHTML = ""

    let oldLength = latestMsg
    let newLength = chatMsgs.length

    let hasNewForeignMessage = false

    for (let i = 0; i < newLength; i++){
        const chatCell = document.createElement("div")
        chatCell.className = "chatCell"
        const iconDiv = document.createElement("div")
        iconDiv.className = "chatCellI"
        iconDiv.innerHTML = `<i class="fa-solid fa-user"></i>`
        const leftDiv = document.createElement("div")
        leftDiv.className = "chatCellLeft"
        const senderDiv = document.createElement("div")
        senderDiv.className = "chatCellLeftDiv bluechatCellLeftDiv"
        senderDiv.textContent = chatMsgs[i].sender
        const messageDiv = document.createElement("div")
        messageDiv.className = "chatCellLeftDiv"
        messageDiv.textContent = chatMsgs[i].message
        const spacer = document.createElement("div")
        spacer.style.height = "20px"
        leftDiv.appendChild(senderDiv)
        leftDiv.appendChild(messageDiv)
        leftDiv.appendChild(spacer)

        chatCell.appendChild(iconDiv)
        chatCell.appendChild(leftDiv)

        chat.appendChild(chatCell)
        const gap = document.createElement("div")
        gap.style.marginTop = "10px"
        chat.appendChild(gap)
        if (chatInitialized && i >= oldLength) {
            if (chatMsgs[i].sender !== myname) {
                hasNewForeignMessage = true
            }
        }
    }

    if (chatInitialized && hasNewForeignMessage) {
        fetch(`https://${GetParentResourceName()}/newMsgNotify`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        })
    }

    if (oldLength < newLength){
        chat.scrollTop = chat.scrollHeight
    }

    latestMsg = newLength
    chatInitialized = true
}

function deleteopened(){
    fetch(`https://${GetParentResourceName()}/deleteopened`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({opened:opened})
    })
}



function updateAdmin(){
    if (admin==true){
        fetch(`https://${GetParentResourceName()}/updateAdmin`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        })
    }
}

function showAdmin(res){
    document.getElementById('admin').style.display = "block"
    document.getElementById('adminActiveReps').innerHTML = "";
    document.getElementById('adminWaitingReps').innerHTML = "";

    let hasWaiting = false;
    let hasActive = false;
    let hasHistory = false;

    for (let i = res.length - 1; i >= 0; i--) {
        if (res[i].status == "waiting") {
            hasWaiting = true;
            document.getElementById('adminWaitingReps').innerHTML +=
                `<div class="repListCell" onclick="playClick(); openPlayerReport(${res[i].id}, 'waiting')">
                    <div class="repListCellTick">
                        <i class="fa-solid fa-ticket"></i>
                    </div>
                    <div class="repListCellCont">
                        <div class="repListCellContCell">${res[i].header}</div>
                        <div class="repListCellContCell">${formatDate2(res[i].date)} &#9830; ${res[i].name} &#9830; ${res[i].type} &#9830;RID:${res[i].id}</div>
                    </div>
                </div>`;
        }

        else if (res[i].status == "solving") {
            hasActive = true;
            document.getElementById('adminActiveReps').innerHTML +=
                `<div class="repListCell" onclick="playClick(); openPlayerReport(${res[i].id}, 'active')">
                    <div class="repListCellTick">
                        <i class="fa-solid fa-ticket"></i>
                    </div>
                    <div class="repListCellCont">
                        <div class="repListCellContCell">${res[i].header}</div>
                        <div class="repListCellContCell">${formatDate2(res[i].date)} &#9830; ${res[i].name} &#9830; ${res[i].type} &#9830;RID:${res[i].id}</div>
                    </div>
                </div>`;
        }
    }
    if (!hasWaiting) {
        document.getElementById('adminWaitingReps').innerHTML =
            `<div class="noreport">${noreport}</div>`;
    }

    if (!hasActive) {
        document.getElementById('adminActiveReps').innerHTML =
            `<div class="noreport">${noreport}</div>`;
    }

}

function markasdone(){
    if (admin==true){
        fetch(`https://${GetParentResourceName()}/markasdone`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({opened:opened})
        })
    }
}

function duty(){
    if (admin==true){
        document.getElementById('dutyBtn').style.display = "flex"
    } else{
        document.getElementById('dutyBtn').style.display = "none"
    }
    fetch(`https://${GetParentResourceName()}/setduty`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    })
}
function startsolving(){
    if (admin==true){
        fetch(`https://${GetParentResourceName()}/startsolving`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({opened:opened})
        })
    }
}





function transcript() {
    if (admin==true){
        fetch(`https://${GetParentResourceName()}/transcript`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({opened:opened})
        })
    }
}

function teleport(){
    if (admin==true){
        fetch(`https://${GetParentResourceName()}/teleport`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({opened:opened})
        })
    }
}

function goback(){
    if (admin==true){
        fetch(`https://${GetParentResourceName()}/goback`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        })
    }
} 

const btn = document.getElementById("wipebtn")
const bar = document.getElementById("managerdelbar")
let width = 0
let holdInterval = null
let last = 0
btn.addEventListener("mousedown", () => {
    bar.style.display = "block"
    holdInterval = setInterval(() => {
        if (width < 80) {
            width += 0.05
            bar.style.width = width + "%"
            if (Math.floor(width)%10==0 && last!=Math.floor(width)){
                playClick()
                last = Math.floor(width)
            }
        } else {
            clearInterval(holdInterval)
            reset()
            last = 0
            if (manager==true){
                fetch(`https://${GetParentResourceName()}/wipeout`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({})
                })
            }
        }
    }, 10)
})
btn.addEventListener("mouseup", reset)
btn.addEventListener("mouseleave", reset)
function reset() {
    clearInterval(holdInterval)
    width = 0
    bar.style.width = "0px"
    bar.style.display = "none"
}


function updateMngmnt(){
    if (manager==true){
        fetch(`https://${GetParentResourceName()}/updmng`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        })
    }
}

function updatedMng(res) {

    document.getElementById('mngClosed').innerHTML = ""

    let solved = 0
    let hasHistory = false
    let admins = {}

    document.getElementById('total').innerHTML = res.length

    for (let i = res.length - 1; i >= 0; i--) {

        if (res[i].status == "closed") {

            if (res[i].admin != null) {
                solved++

                let admin = res[i].admin

                if (!admins[admin]) {
                    admins[admin] = 1
                } else {
                    admins[admin]++
                }
            }

            hasHistory = true

            document.getElementById('mngClosed').innerHTML +=
                `<div class="repListCell" onclick="playClick(); openPlayerReport(${res[i].id}, 'waiting')" style="height: 9vh">
                    <div class="repListCellTick">
                        <i class="fa-solid fa-ticket"></i>
                    </div>
                    <div class="repListCellCont">
                        <div class="repListCellContCell">${res[i].header}</div>
                        <div class="repListCellContCell" style="margin-top: -10px">
                            ${formatDate2(res[i].date)} &#9830; ${res[i].type} &#9830; RID:${res[i].id} &#9830; ${res[i].owner}
                        </div>
                    </div>
                </div>`
        }
    }

    document.getElementById('solved').innerHTML = solved
    if (!hasHistory) {
        document.getElementById('mngClosed').innerHTML =
            `<div class="noreport">${noreport}</div>`
    }
    const container = document.getElementById('activityadmin')
    container.innerHTML = ""
    const values = Object.values(admins)
    if (values.length === 0) return
    const max = Math.max(...values)
    for (const admin in admins) {
        const percent = max === 0 ? 0 : (admins[admin] / max) * 100
        container.innerHTML += `
            <div class="graphBox">
                <div class="graph" style="height: ${percent}%">
                    ${admins[admin]}
                </div>
                <div class="graphAdmin">
                    ${admin}
                </div>
            </div>
        `
    }
}