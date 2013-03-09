// グラフに表示する系列名を見つけ、seriesにpushする
// csvの各行はハッシュになっている。keyは、x軸のラベル(Dateが多い) or Target or 系列名。valueはそれぞれの値。
function get_series_names(display_series_type, series, csv){
  var first_row;
  $.each(csv, function(i, row) {
      if ( i==0 ) {
        first_row = row;
        return false; // break in jquery
      }
  });

  console.log(first_row);
  // Object
  //  Date: "2012-10-09"
  //  Mobile: "111"
  //  PC: "1111"
  //  Total: "11111"
  //  Touch: "111111"
  //  __proto__: Object

  var x_axis_label = dataset.x_axis_value_label; // Dateとか
  var y_series_labels = dataset.y_series_labels; // UUとか

  if(display_series_type === "not_total"){
    for ( var key in first_row ){
      if ( key == x_axis_label || key.toLowerCase() == 'total' )
        continue;
  
      if ( dataset.chart_type == 'cumlative_column' && key == 'Target' )
        continue;

      series.push(key);
    }
  }
  else if(display_series_type === 'only_total') {
    for ( var key in first_row ){
       if ( key.toLowerCase() != 'total' && key != 'Target' )
        continue;
  
      series.push(key);
    }
  }
  else if(display_series_type === 'all') {
    for ( var key in first_row ){
      if( key == x_axis_label )
        continue;

      series.push(key);
    }
  }
  else{
    console.log("in chart.js, in get_series_names, not supported value comes.");
  }
}


// グラフ描画の entry point
function draw_graph(dataset){

  d3.csv(dataset.data_url, function(csv) {
    var graph, value;
    var series = new Array();
    var element_id = "#chart";

    get_series_names(dataset.display_series_type, series, csv);

    switch (dataset.chart_type) {
      case 'column':
        if ( series.join().match("Target") ) {
          console.log("column, target");
          graph = column_and_target_chart(element_id, csv, dataset.x_axis_value_label, series, null, false);
        } else {
          console.log("column");
          graph = column_chart(element_id, csv, dataset.x_axis_value_label, series, null, null, false);
        }
        break;
      case 'line':
        console.log("line");
        graph = line_chart(element_id, csv, dataset.x_axis_value_label, series, null);
        break;
      case 'cumlative_column':
        console.log("cumlative_column");
        graph = column_chart(element_id, csv, dataset.x_axis_value_label, series, null, null, true);
        break;
           
    }
  });
}

