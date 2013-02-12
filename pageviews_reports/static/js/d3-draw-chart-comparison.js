
/*
     == The data parameter to this function should be of the following form ==

{"mimetype": "text/html",
  "1-13dec": 1,
  "14-31dec": 2,
},
{"mimetype": "text/javascript",
  "1-13dec": 6,
  "14-31dec": 10,
}

*/


function drawMimeTypeComparisonChart(data, containerId) {
  data = data.sort(function(a,b){
    var sumA = 0;
    var sumB = 0;
    for(key in a) {
      if(key != "mimetype" && a[key] ) {
        sumA += a[key];
      };
    };
    for(key in b) {
      if(key != "mimetype" && b[key] ) {
        sumB += b[key];
      };
    };

    return sumB - sumA;
  });

  // get only top #10 
  data = data.slice(0,10);

  var margin = 
  {
   top    : 20,
   right  : 20,
   bottom : 30,
   left   : 40,
  },
  width  = 600 - margin.left - margin.right ,
  height = 500 - margin.top  - margin.bottom;

  var x0 = 
  d3
  .scale
  .ordinal()
  .rangeRoundBands([0, width], .1);

  var x1 = d3.scale.ordinal();

  var y = 
  d3
  .scale
  .linear()
  .range([height, 50]);

  var color = 
  d3
  .scale
  .ordinal()
  .range(["#98abc5", "#8a89a6", "#7b6888", "#6b486b", "#a05d56", "#d0743c", "#ff8c00"]);

  var xAxis = 
  d3
  .svg
  .axis()
  .scale(x0)
  .orient("bottom");

  var yAxis = d3
  .svg
  .axis()
  .scale(y)
  .orient("left")
  .tickFormat(d3.format(".2s"));

  var svg = d3
  .select("#"+containerId)
  .append("svg")
  .attr("width", width + margin.left + margin.right)
  .attr("height", height + margin.top + margin.bottom)
  .append("g")
  .attr("transform", "translate(" + margin.left + "," + margin.top + ")");


  var mimetypeNames = d3.keys(data[0]).filter(function(key) { return key !== "mimetype"; });

  data.forEach(function(d) {
    d.mimetypeDensities = mimetypeNames.map(function(name) { return {name: name, value: +d[name]}; });
  });

  x0.domain(data.map(function(d) { return d.mimetype; }));
  x1.domain(mimetypeNames).rangeRoundBands([0, x0.rangeBand()]);
  y.domain([0, d3.max(data, function(d) { return d3.max(d.mimetypeDensities, function(d) { return d.value; }); })]);

  svg.append("g")
  .attr("class", "x axis")
  .attr("transform", "translate(0," + height + ")")
  .call(xAxis);

  svg.append("g")
  .attr("class", "y axis")
  .call(yAxis)
  .append("text")
  .attr("transform", "rotate(-90)")
  .attr("y", 6)
  .attr("dy", ".71em")
  .style("text-anchor", "end")
  .text("requests");

  var mimetype = svg.selectAll(".mimetype")
  .data(data)
  .enter().append("g")
  .attr("class", "g")
  .attr("transform", function(d) { return "translate(" + x0(d.mimetype) + ",0)"; });

  mimetype.selectAll("rect")
  .data(function(d) { return d.mimetypeDensities; })
  .enter().append("rect")
  .attr("width", x1.rangeBand())
  .attr("x", function(d) { return x1(d.name); })
  .attr("y", function(d) { return y(d.value); })
  .attr("height", function(d) { return height - y(d.value); })
  .style("fill", function(d) { return color(d.name); });

  var legend = svg.selectAll(".legend")
  .data(mimetypeNames.slice().reverse())
  .enter().append("g")
  .attr("class", "legend")
  .attr("transform", function(d, i) { return "translate(0," + i * 20 + ")"; });

  legend.append("rect")
  .attr("x", width - 18)
  .attr("width", 18)
  .attr("height", 18)
  .style("fill", color);

  legend.append("text")
  .attr("x", width - 24)
  .attr("y", 9)
  .attr("dy", ".35em")
  .style("text-anchor", "end")
  .text(function(d) { return d; });

};
