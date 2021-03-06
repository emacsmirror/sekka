//
//   Copyright (c) 2017  Kiyoka Nishiyama  <kiyoka@sumibi.org>
//
//   Redistribution and use in source and binary forms, with or without
//   modification, are permitted provided that the following conditions
//   are met:
//
//   1. Redistributions of source code must retain the above copyright
//      notice, this list of conditions and the following disclaimer.
//
//   2. Redistributions in binary form must reproduce the above copyright
//      notice, this list of conditions and the following disclaimer in the
//      documentation and/or other materials provided with the distribution.
//
//   3. Neither the name of the authors nor the names of its contributors
//      may be used to endorse or promote products derived from this
//      software without specific prior written permission.
//
//   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
//   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
//   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
//   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
//   OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
//   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
//   TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
//   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
//   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

let kouhoBox = null;
let keydownCount = 0;
let keyBuffer = "";
let henkanBusy = false;

function domAddEventListener(element) {
    if (element.addEventListener) {
        element.addEventListener("keydown", keyDownHandler);
    } else if (element.attachEvent) {
        element.attachEvent("onkeydown", keyDownHandler);
    }
}

// add EventListener to oinput/textarea
let g_names = [];
let g_ids = [];
function hookToTextArea() {
    $('input[type=text], textarea').each(
        function (index) {
            let input = $(this);
            let name = input.attr('name');
            let id = input.attr('id');
            if (null != name) {
                g_names.push(name);
            }
            if (null != id) {
                g_ids.push(id);
            }

            domAddEventListener(input.get(0));
        }
    );
}
hookToTextArea();

// call status api on sekka server.
function sekkaRequest_status(baseUrl) {
    chrome.runtime.sendMessage({ baseUrl: baseUrl, api: "status" }, function (response) {
        console.log(response);
    });
}

function henkanResponseHandler(target, resp, startPos, endPos) {
    let first_entry = resp[0];
    let kanji = first_entry[0];
    let textOfTextarea = $(target).val();
    jutil = new JapaneseUtil();
    let replacedString = jutil.replaceString(textOfTextarea, kanji + keyBuffer, startPos, endPos);

    $(target).val(replacedString);

    domutil = new DomUtil();
    domutil.moveToPos(target, startPos + kanji.length + keyBuffer.length);

    let headText = textOfTextarea.substring(0, startPos)
    let yomi = textOfTextarea.substring(startPos, endPos);
    let tailText = textOfTextarea.substring(endPos);

    kouhoBox = new KouhoBox(resp, textOfTextarea, headText, yomi, tailText, endPos)
    //alert("kanji:" + kanji + " startPos:" + startPos + " endPos:" + endPos + "repalced:" + replacedString);
}

// call api on sekka server.
function sekkaRequest(target, baseUrl, apiname, argHash, startPos, endPos) {
    keydownCount = 0;
    keyBuffer = "";
    henkanBusy = true;
    chrome.runtime.sendMessage({ baseUrl: baseUrl, api: apiname, argHash: argHash }, function (response) {
        if (null == response) {
            alert("Error: can't connect to sekka server [" + baseUrl + "]");
        }
        else if ('henkan' === apiname) {
            henkanResponseHandler(target, response.result, startPos, endPos);
        }
        henkanBusy = false;
    });
}

function henkanAction(target, ctrl_key, shift_key, key_code) {
    sekkaSetting = new SekkaSetting();
    sekkaSetting.load();
    domutil = new DomUtil();
    let kouhoWindow = new KouhoWindow();

    let consumeFlag = false;
    let henkanFlag = false;
    if (ctrl_key && key_code == 74) { // CTRL+J
        jutil = new JapaneseUtil();
        consumeFlag = true;
        if (henkanBusy) {
            console.log("ctrl+j(busy)");
        }
        else {
            console.log("ctrl+j");
            let textOfTextarea = $(target).val();
            let cursorPosition = $(target).prop("selectionStart");
            let [prevYomi, yomi, startPos, endPos] = jutil.takePrevCursorAscii(textOfTextarea, cursorPosition);
            yomi = jutil.trimSlash(yomi);
            if (0 < yomi.length) {
                // アスキー文字列があったら、変換候補を捨てる。
                kouhoBox = null;
            }
            if (null != kouhoBox) {
                if (kouhoBox.isSelectingPos(prevYomi + yomi)) {
                    // カーソル位置を次の候補で差し替える。
                    {
                        let [origText, headText, yomi, tailText] = kouhoBox.getTextSet();
                        let kouhoStr = kouhoBox.getNextKouho();
                        $(target).val(headText + kouhoStr + tailText);
                        domutil.moveToPos(target, headText.length + kouhoStr.length);
                    }
                    let html = kouhoBox.getKouhoGuideHtml();
                    // 候が多すぎる時は、オーバレイで候補をガイドしてくれる。
                    if (1 < kouhoBox.getIndex()) {
                        kouhoWindow.display(target, html);
                    }
                }
            }
            else {
                sekkaRequest(target,
                    sekkaSetting.getBaseUrl(),
                    'henkan',
                    { 'userid': sekkaSetting.getUsername(), 'format': 'json', 'yomi': yomi, 'method': 'normal', 'limit': '0' },
                    startPos,
                    endPos
                );
            }
            henkanFlag = true; // 変換コマンド実行した
        }
    }
    else if (ctrl_key && key_code == 70) { // CTRL+F
        console.log("ctrl+f");
        consumeFlag = true;
        domutil.moveForward(target);
    }
    else if (ctrl_key && key_code == 66) { // CTRL+B
        console.log("ctrl+b");
        consumeFlag = true;
        domutil.moveBackward(target);
    }
    else if (ctrl_key && key_code == 72) { // CTRL+H
        console.log("ctrl+h");
        consumeFlag = true;
        domutil.backspace(target);
    }
    else if (ctrl_key && key_code == 68) { // CTRL+D
        console.log("ctrl+d");
        consumeFlag = true;
        domutil.deleteNextChar(target);
    }
    else if (ctrl_key && key_code == 71) { // CTRL+G (revert)
        console.log("ctrl+g");
        consumeFlag = true;
        if (null != kouhoBox) {
            let origText = kouhoBox.getOrigText();
            let origPos = kouhoBox.getOrigPos();
            $(target).val(origText);
            domutil.moveToPos(target, origPos);
            kouhoBox = null;
        }
    }
    else if (ctrl_key && key_code == 65) { // CTRL+A
        console.log("ctrl+a");
        if (0 == domutil.getCursorPosition(target)) {
            // すでに行頭にいれば、既存の全選択が発動
        }
        else {
            consumeFlag = true;
            domutil.moveToBeginningOfLine(target);
        }
    }
    else if (ctrl_key && key_code == 69) { // CTRL+E
        console.log("ctrl+e");
        consumeFlag = true;
        domutil.moveToEndOfLine(target);
    }
    else if (ctrl_key && key_code == 75) { // CTRL+K
        console.log("ctrl+k");
        consumeFlag = true;
        domutil.killLine(target);
    }
    else if (key_code == 38 || key_code == 40) { // ↑矢印 or ↓矢印
        if (kouhoWindow.isDisplay()) {
            if (null != kouhoBox) {
                let kouhoStr = null;
                if (key_code == 38) {
                    console.log("↑");
                    kouhoBox.getPrevKouho();
                }
                else if (key_code == 40) {
                    console.log("↓");
                    kouhoBox.getNextKouho();
                }
                let html = kouhoBox.getKouhoGuideHtml();
                kouhoWindow.display(target, html);
            }
            henkanFlag = true;
            consumeFlag = true;
        }
    }
    else if (key_code == 13) { // Enter key
        if (kouhoWindow.isDisplay()) {
            // カーソル位置を次の候補で差し替える。
            let [origText, headText, yomi, tailText] = kouhoBox.getTextSet();
            let kouhoStr = kouhoBox.getCurKouho();
            $(target).val(headText + kouhoStr + tailText);
            domutil.moveToPos(target, headText.length + kouhoStr.length);
            kouhoWindow.discard();
            henkanFlag = true;
            consumeFlag = true;

            // 変換候補の確定（学習）APIを呼ぶ
            let key = kouhoBox.getCurKey();
            sekkaRequest(target,
                sekkaSetting.getBaseUrl(),
                'kakutei',
                { 'userid': sekkaSetting.getUsername(), 'format': 'json', 'key': key, 'tango': kouhoStr },
                0,
                0
            );
        }
    }
    else if (henkanBusy && !ctrl_key) {
        keydownCount++;
        let str = String.fromCharCode(key_code);
        if (!shift_key) {
            str = str.toLowerCase();
        }
        str = jutil.takeLastAscii(str);
        keyBuffer += str;
        consumeFlag = true;
    }

    if (!henkanFlag) {
        kouhoWindow.discard();
    }

    return consumeFlag;
}

// key down handing for input/textare
function keyDownHandler(e) {
    let hit = false;
    let target = $(e.target);

    $.each(g_names, function () {
        if (this == target.attr('name')) {
            //alert("hit:" + this);
            hit = true;
        }
    });
    $.each(g_ids, function () {
        if (this == target.attr('id')) {
            //alert("hit:" + this);
            hit = true;
        }
    });

    if (hit) {
        let key_code = e.keyCode;
        let shift_key = e.shiftKey;
        let ctrl_key = e.ctrlKey;
        let alt_key = e.altKey;

        if (false) {
            console.log("code:" + key_code);
            console.log("shift:" + shift_key);
            console.log("ctrl" + ctrl_key);
            console.log("alt:" + alt_key);
        }

        if (henkanAction(target, ctrl_key, shift_key, key_code)) {
            e.preventDefault();
            e.stopPropagation();
        }
    }
}
