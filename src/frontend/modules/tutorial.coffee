###

Copyright (c) 2011-2013  Voicious

This program is free software: you can redistribute it and/or modify it under the terms of the
GNU Affero General Public License as published by the Free Software Foundation, either version
3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this
program. If not, see <http://www.gnu.org/licenses/>.

###

class Tutorial extends Module
    constructor      : (emitter) ->
        super emitter
        do @appendHTML

    appendHTML       : () ->
        html = ($ '<button id="tutoModeBtn" href="javascript:void(0)" onclick="javascript:introJs().start();">
                     <span id="spanTutoMode" class="icon iconOther icon-question"></span>
                     <p id="labelTutoMode">Help</p>
                   </button>'
        )
        html.appendTo "#sidebarAcc"

if window?
     window.Tutorial = Tutorial
