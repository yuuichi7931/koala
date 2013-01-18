
function default_color_scheme() {
    return ['#ff0000','#ff7f0e','#2ca02c','#d62728','#9467bd','#8c564b','#e377c2','#7f7f7f','#bcbd22','#17becf'];
}

function select_color(column,index) {
  var colors = default_color_scheme();
  color = colors[index];
  if ( column == "Target" ) {
    color = "#ff9090";
  }
  console.log(color);
  return color;
}

function have_no_data(data){
  return data.length == 0 ? true : false;
}

function set_error_message(element_id){
  var e = $("<div/>").attr("id", "no_data_error").css("color", "red").text("指定された期間のデータは存在しません。日付を指定し直してください。");
  $(element_id).before(e);
  console.log("chart_template.js, have_no_data, 指定された期間のデータが存在しません");
}

function column_chart(element_id, csv, x_var, series, color, title, normalized) {
  _column_chart(element_id, csv, x_var, series, color, 0, 0, title, normalized);
}

function _column_chart(element_id, csv, x_var, series, color, w, h, title, normalized) {
    if (normalized) {
        var denom = [];
        csv.map(function(row) {
            var sum = 0;
            $.each(series, function(i, column) {
                sum += parseFloat(row[column]);
            });
            denom.push(sum);
        });
    }

    var data = series.map(function(column) {
        var i = 0;
        return {
          key: column, 
          bar : true,
          values: csv.map(function(d) {
                  var val = {
                    x: d[x_var], 
                    y: parseFloat(d[column]) };
                  
                  if (normalized) {
                      val.y /= denom[i];
                  }

                  i += 1;

                  return val;
              }),
          color: select_color(column,series.indexOf(column))
        };
    });

    var chart = nv.models.multiBarChart()
          .margin({top: 30, right: 90, bottom: 50, left: 90})
          .showControls(false);

    nv.addGraph(function() {

      chart.xAxis.tickPadding(10);

      if (normalized) {
        chart.yAxis.tickFormat(d3.format(',.1f'));
      } else {
        chart.yAxis.tickFormat(d3.format(',f'));
      }

      extend_chart_height(element_id, data);

      if(have_no_data(data))
        set_error_message(element_id);

      d3.select(element_id + ' svg').datum(data).transition().duration(10).call(chart);

        nv.utils.windowResize(chart.update);

        return chart;
    }, function(){ sortables_init() });

    return chart;
}

function column_and_target_chart(element_id, csv, x_var, series, color, title, normalized){
  _column_and_target_chart(element_id, csv, x_var, series, color, 0, 0, title, normalized);
}

function _column_and_target_chart(element_id, csv, x_var, series, color, w, h, title, normalized) {

  var min = 0, max = 0, stack = new Array();

  var data = series.map(function(column) {
    if ( column == "Target" ) {
      var i = 0;
      return {
        key: column, 
        values: csv.map(function(d) {
            var val = { 
              x: new Date(d[x_var]).getTime(), //( Date.parse(d[x_var].replace(/-/g,'/'))), 
              y: parseFloat(d[column]) };
            if ( d[column] < min ) { min = d[column];};
            if ( d[column] > max ) { max = d[column];};
            i += 1;
            return val;
          }),
        color: select_color(column,series.indexOf(column))
      };
    } else {
      var i = 0;
      return {
        key: column, 
        bar: true,
        values: csv.map(function(d) {
            var val = { 
              x: new Date(d[x_var]).getTime(), //( Date.parse(d[x_var].replace(/-/g,'/'))), 
              y: parseFloat(d[column]) };
            if ( !stack[i] ) { stack[i] = 0;}
            stack[i] += parseFloat(d[column]);
            if ( d[column] < min ) { min = d[column];};
            if ( stack[i] > max ) { max = stack[i];};
            i += 1;
            return val;
          })
        //color: select_color(column,series.indexOf(column))
      };
    }
  });

  var chart = nv.models.linePlusBarChart()
        .margin({top: 30, right: 90, bottom: 50, left: 90})
        .x(function(d,i) { return i })
        .color(default_color_scheme());

  // force set scale
  chart.lines.forceY([min,max]);
  chart.bars.forceY([min,max]);

  nv.addGraph(function() {

    chart.xAxis.tickFormat(function(d){
      var dx = data[0].values[d] && data[0].values[d].x || 0;
      return d3.time.format('%Y-%m-%d')(new Date(dx));
    }).tickPadding(10);

    //chart.xAxis.tickFormat(function(d){return d3.time.format('%Y-%m-%d')(new Date(d)});
    chart.yAxis1.tickFormat(d3.format(',f'));
    chart.yAxis2.tickFormat(d3.format(',f'));

    if(have_no_data(data))
      set_error_message(element_id);

    d3.select(element_id + ' svg').datum(data).transition().duration(10).call(chart);

    // set line opacity
    d3.select('.linesWrap')
        .datum(data)
        .style("opacity",0.7);

    nv.utils.windowResize(chart.update);

    return chart;
  }, function(){ sortables_init() });

  return chart;
}

function line_chart(element_id, csv, x_var, series, color, title) {
  _line_chart(element_id, csv, x_var, series, color, 0, 0, title)
}

function _line_chart(element_id, csv, x_var, series, color, w, h, title) {
    var data = series.map(function(column) {
        return {
            key: column, 
            values: csv.map(function(d) {
                    var val = {
                      x: new Date(d[x_var]).getTime(), 
                      y: parseFloat(d[column]) };

                    return val;
                }),
            color: select_color(column,series.indexOf(column))
        };
    });

    // Draw Graph
    var format = d3.time.format("%Y-%m-%d");
    var chart = nv.models.lineChart().margin({top: 30, right: 90, bottom: 50, left: 90});
    
    nv.addGraph(function() {  
      chart.xAxis
          .tickFormat(function (d){ return format(new Date(d)); })
          .tickPadding(10)
          ;

      chart.yAxis
          .tickFormat(d3.format('.f'))
          .tickPadding(10)
          ;

      chart.forceY([0]);

    if(have_no_data(data))
      set_error_message(element_id);

      d3.select(element_id + ' svg').datum(data).transition().duration(500).call(chart);

      nv.utils.windowResize(chart.update);

      return chart;
    }, function(){ sortables_init(); });

    return chart;
}
