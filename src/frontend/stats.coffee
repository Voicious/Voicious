###

Copyright (c) 2011-2012  Voicious

This program is free software: you can redistribute it and/or modify it under the terms of the
GNU Affero General Public License as published by the Free Software Foundation, either version
3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License along with this
program. If not, see <http://www.gnu.org/licenses/>.

###

class Chart
    constructor: (@name) ->
        @prevPoint = null
        @_jqChart = PrivateValue.GetOnly ($ '#' + @name)
        (do @_jqChart.get).bind "plothover", @displayTickData

    # Checks for new data and displays it after.
    displayTickData: (event, pos, item) =>
        if item?
            if @prevPoint isnt item.dataIndex
                @prevPoint = item.dataIndex
                do $("#tooltip").remove
                x = item.datapoint[0]
                y = item.datapoint[1]
                date = new Date(x)
                x = do date.toLocaleDateString
                @showTooltip item.pageX, item.pageY, item.series.label + "' number on " + x + " : " + y
        else
            do $("#tooltip").remove
            @prevPoint = null

    # Displays an updated tooltip with its new position.
    showTooltip: (x, y, contents) =>
        $('<div id="tooltip">' + contents + '</div>').css({
              position: 'absolute',
              display: 'none',
              top: y + 5,
              left: x + 5,
              border: '1px solid #fdd',
              padding: '2px',
              'background-color': '#fee',
              opacity: 0.80
            }).appendTo("body").fadeIn 200

$(document).ready ->
    charts =
        '#chart1' : new Chart 'chart1'
        '#chart2' : new Chart 'chart2'