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

class DomUtil {
    moveForward(target) {
        this.moveOffset(target, 1)
    }

    moveBackward(target) {
        this.moveOffset(target, -1)
    }

    moveToBeginningOfLine(target) {
        this.moveToPos(target, 0)
    }

    moveToEndOfLine(target) {
        let origText = $(target).val();
        this.moveToPos(target, origText.length);
    }

    getCursorPosition(target) {
        return $(target).prop("selectionStart");
    }

    // Emacs's Backspace
    backspace(target) {
        let cursorPosition = $(target).prop("selectionStart");
        let origText = $(target).val();
        let jutil = new JapaneseUtil();
        let [prevStr, nextStr] = jutil.takePrevNextString(origText, cursorPosition);
        if (0 == prevStr.length) {
            return;
        }
        else {
            prevStr = prevStr.substring(0, prevStr.length - 1);
            $(target).val(prevStr + nextStr);
            this.moveToPos(target, cursorPosition - 1);
        }
    }

    // Emacs's delete
    deleteNextChar(target) {
        let cursorPosition = $(target).prop("selectionStart");
        let origText = $(target).val();
        let jutil = new JapaneseUtil();
        let [prevStr, nextStr] = jutil.takePrevNextString(origText, cursorPosition);
        if (0 == nextStr.length) {
            return;
        }
        else {
            nextStr = nextStr.substring(1);
            $(target).val(prevStr + nextStr);
            this.moveToPos(target, cursorPosition);
        }
    }

    // Emacs's kill-line
    killLine(target) {
        let cursorPosition = $(target).prop("selectionStart");
        let origText = $(target).val();
        let jutil = new JapaneseUtil();
        let [prevStr, nextStr] = jutil.takePrevNextString(origText, cursorPosition);
        if (0 == nextStr.length) {
            return;
        }
        else {
            $(target).val(prevStr);
            this.moveToPos(target, cursorPosition);
        }
    }


    moveOffset(target, offset) {
        let cursorPosition = $(target).prop("selectionStart");
        let elem = target[0];
        let targetPosition = cursorPosition + offset;
        this.moveToPos(target, targetPosition);
    }

    moveToPos(target, targetPosition) {
        let cursorPosition = $(target).prop("selectionStart");
        let elem = target[0];
        if (elem.setSelectionRange) {
            elem.setSelectionRange(targetPosition, targetPosition);
        } else if (elem.selectionStart) {
            elem.selectionStart = targetPosition;
            elem.selectionEnd = targetPosition;
        } else if (elem.createTextRange) {
            let range = elem.createTextRange();
            range.collapse(true);
            range.moveEnd('character', targetPosition);
            range.moveStart('character', targetPosition);
            range.select();
        }
    }
}